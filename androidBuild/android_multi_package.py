# coding=utf-8
import json
import os
import sys
import platform
import stat
import time
import datetime
import shlex
import subprocess
import shutil

import logging
import logging.handlers
import getpass

import optparse

__author__ = 'sinlov'

reload(sys)
sys.setdefaultencoding('utf-8')

is_verbose = False
root_run_path = os.getcwd()
this_tag = 'android_multi_build_'

"""
执行默认超时时间 60 * 1 秒
"""
out_of_time_default = 60 * 1
"""
执行单位克隆超时时间 60 * 30 秒
"""
out_of_time_clone = 60 * 30
"""
执行单位构建超时时间 60 * 20 秒
"""
out_of_time_build = 60 * 20

build_gradle_properties = 'gradle.properties'


def find_now_time_format(format_time=str):
    """获取当前时间格式化的函数
    :param format_time:
    格式化参数:
      %y 两位数的年份表示（00-99）
      %Y 四位数的年份表示（000-9999）
      %m 月份（01-12）
      %d 月内中的一天（0-31）
      %H 24小时制小时数（0-23）
      %I 12小时制小时数（01-12）
      %M 分钟数（00=59）
      %S 秒（00-59）
      %a 本地简化星期名称
      %A 本地完整星期名称
      %b 本地简化的月份名称
      %B 本地完整的月份名称
      %c 本地相应的日期表示和时间表示
      %j 年内的一天（001-366）
      %p 本地A.M.或P.M.的等价符
      %U 一年中的星期数（00-53）星期天为星期的开始
      %w 星期（0-6），星期天为星期的开始
      %W 一年中的星期数（00-53）星期一为星期的开始
      %x 本地相应的日期表示
      %X 本地相应的时间表示
      %Z 当前时区的名称
      %% %号本身

    :return: time string
    """
    return time.strftime(format_time, time.localtime(time.time()))


def init_logger(first_tag, sec_tag=str):
    global logger
    log_file = first_tag + sec_tag + '.log'
    handler = logging.handlers.RotatingFileHandler(log_file, maxBytes=1024 * 1024, backupCount=5)
    fmt = '%(asctime)s - %(filename)s:%(lineno)s - %(name)s - %(levelname)s - %(message)s'
    formatter = logging.Formatter(fmt)
    handler.setFormatter(formatter)
    logger = logging.getLogger(str(getpass.getuser()))
    logger.addHandler(handler)
    logger.setLevel(logging.DEBUG)
    return logger


def init_logger_by_time(tag=str):
    # type: (str) -> Logger
    return init_logger(tag, find_now_time_format('%Y_%m_%d_%H_%M_%S'))


def log_printer(msg, lev=str, must=False):
    # type: (str, str, bool) -> None
    if is_verbose or must:
        print msg,
    if lev == 'i':
        logger.info(msg)
    elif lev == 'd':
        logger.debug(msg)
    elif lev == 'w':
        logger.warning(msg)
    elif lev == 'e':
        logger.error(msg)
    else:
        logger.info(msg)


def is_platform_windows():
    sys_str = platform.system()
    if sys_str == "Windows":
        return True
    else:
        return False


def check_dir_or_file_is_exist(abs_path=str):
    return os.path.exists(abs_path)


def change_files_write(path=str):
    # type: (str) -> None
    for root, dirs, files in os.walk(path):
        for name in files:
            os.chmod(os.path.join(root, name), stat.S_IWRITE)
    logger.info('change change_files_write success')


def del_dot_head_files(path=str):
    try:
        for root, dirs, files in os.walk(path):
            for name in files:
                if name.startswith("."):
                    os.remove(os.path.join(root, name))
        logger.info("delete path " + path + " success!")
    except Exception, e:
        logger.error(e)
        print e


def replace_text(t_file=str, s_str=str, r_str=str):
    try:
        lines = open(t_file, 'r').readlines()
        f_len = len(lines) - 1
        for i in range(f_len):
            if s_str in lines[i]:
                lines[i] = lines[i].replace(s_str, r_str)
        open(t_file, 'w').writelines(lines)
        logger.info('replace text success | path: ' + t_file + ' |from: ' + s_str + ' |to: ' + r_str)
    except Exception, e:
        logging.error(e)
        print e


def exec_cli_print_line(cli_line=str, cwd=None):
    # type: (str, str) -> None
    """只会捕获输出，打印到日志里面
    :param cli_line: 执行命令
    :param cwd: 执行目录
    """
    info = "=== cli line ===\n%s\n" % cli_line
    log_printer(info, 'i', True)
    res = subprocess.Popen(cli_line, cwd=None, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    str_info = "cmd_line: %s\n%s" % (cli_line, res.stdout.readline())
    log_printer(str_info, 'i', True)


def execute_cli(cli_string, cwd=None, timeout=None, is_shell=False, is_info=False):
    """执行一个SHELL命令
        封装了subprocess的Popen方法, 支持超时判断，支持读取stdout和stderr
        如果没有指定标准输出和错误输出的管道，因此会打印到屏幕上
        另外的，可以通过返回的 returncode 来判断是否成执行


        支持超时原理：
            subprocess.poll()方法：检查子进程是否结束了，如果结束了
            设定并返回码，放在subprocess.returncode变量中
    参数:
      :param cli_string 运行命令字符串
      :param cwd 运行命令时更改路径，如果被设定，子进程会直接先更改当前路径到cwd
      :param timeout 超时时间，秒，支持小数，精度0.1秒，默认不输入无超时
      :param is_shell 是否通过shell运行,使用 shlex.split 来解析
      :param is_info 是否同时打印输出
    :return: return class Popen(object)
    :raises: Exception: 执行超时
    """
    if is_shell:
        cmd_string_list = cli_string
    else:
        cmd_string_list = shlex.split(cli_string)
    if timeout:
        end_time = datetime.datetime.now() + datetime.timedelta(seconds=timeout)
    sub = subprocess.Popen(cmd_string_list, cwd=cwd,
                           stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                           stderr=subprocess.PIPE, shell=is_shell,
                           bufsize=4096)
    while sub.poll() is None:
        if is_info:
            print sub.stdout.readline(),
        time.sleep(0.1)
        if timeout:
            if end_time <= datetime.datetime.now():
                raise Exception('Timeout：%s' % cli_string)
    return sub


def exec_cli(cmd_string, cwd=None, time_out=None, is_shell=False):
    """执行一个SHELL命令
        封装了subprocess的Popen方法, 支持超时判断，支持读取stdout和stderr
        默认开启打印执行输出，不可修改
        操时已经使用 max_out_of_time 设置
    参数:
      :param cmd_string 运行命令字符串
      :param cwd 运行命令时更改路径，如果被设定，子进程会直接先更改当前路径到cwd
      :param time_out 超时时间，秒，支持小数，精度0.1秒，默认不输入 超时使用 max_out_of_time 设置
      :param is_shell 是否通过shell运行,使用 shlex.split 来解析
    :return: return class Popen(object)
    :raises: Exception: 执行超时
    """
    try:
        if time_out is None:
            time_out = out_of_time_default
        log_printer('\ncli -> %s\ncwd -> %s\ntimeOut -> %s\nis_shell -> %s\n' % (cmd_string, cwd, time_out, is_shell),
                    'i', True)
        command_out = execute_cli(cmd_string, cwd, time_out, is_shell, True)
        if command_out.returncode == 0:
            str_info = "cmd_line success: %s\n%s" % (cmd_string, str(command_out.stdout.read()))
            command_out.stdout.close()
            log_printer(str_info, 'i', True)
            return True
        else:
            str_info = "cmd_line fail: %s\n%s" % (cmd_string, str(command_out.stderr.read()))
            command_out.stderr.close()
            log_printer(str_info, 'e', True)
            return False
    except Exception, e:
        log_printer('cmd_line %s\nError info %s' % (cmd_string, str(e)), 'e', True)
        return False


def read_json_file(js_path=str):
    if not os.path.exists(js_path):
        log_printer("can not find json file, exit!", 'e', True)
        exit(1)
    try:
        with open(js_path, 'r') as load_js:
            js = json.load(load_js)
        return js
    except Exception, e:
        log_printer('Read json file: %s\n%s\nError, exit!' % (js_path, str(e)), 'e', True)
        exit(1)


def read_json_config(json_path=str):
    # type: (str) -> None
    if not os.path.exists(json_path):
        log_printer("can not find json config, exit!", 'e', True)
        exit(1)
    try:
        with open(json_path, 'r') as load_js:
            config_js = json.load(load_js)
            js_build_path = config_js['build_path']
            js_build_path = os.path.join(root_run_path, js_build_path)
            if not check_dir_or_file_is_exist(js_build_path):
                os.mkdir(js_build_path)
            build_projects = config_js['build_projects']
            for project in build_projects:
                filter_project_config(project, js_build_path)
    except Exception, e:
        log_printer('Read json config file: %s\n%s\nError, exit!' % (json_path, str(e)), 'e', True)
        exit(1)


def git_clone_project_by_branch_and_try_pull(project_url=str, local_path=str, branch=str):
    if check_dir_or_file_is_exist(local_path):
        clone_is_exists = '\n===\nClone project is exist path: \n%s\n===\n' % local_path
        log_printer(clone_is_exists, 'i', True)
    else:
        cmd_line = 'git clone %s -b %s %s' % (project_url, branch, local_path)
        exec_cli_print_line(cmd_line)
    git_branch_check = 'git branch -v'
    exec_cli_print_line(git_branch_check)
    git_pull_head = 'git pull'
    exec_cli_print_line(git_pull_head, local_path)
    gs_cmd = 'git status'
    gs = exec_cli(gs_cmd, local_path)
    if not gs:
        exit(1)


def check_project_version_info_at_gradle_properties(local, version_name, version_code=str):
    gp_path = os.path.join(local, build_gradle_properties)
    if not check_dir_or_file_is_exist(gp_path):
        log_printer('project not found path: %s\exit 1' % gp_path, 'e', True)
        exit(1)
    has_version_name = False
    has_version_code = False
    gp_file = open(gp_path, 'r')
    gp_content = gp_file.readlines()
    for index, content in enumerate(gp_content):
        if version_name in content:
            log_printer('Find version_name: %s' % content)
            has_version_name = True
        if version_code in content:
            log_printer('Find version_code: %s' % content)
            has_version_code = True
    gp_file.close()
    if has_version_name and has_version_code:
        log_printer('Check version by gradle.properties success', 'i', True)
    else:
        log_printer('Check version by gradle.properties fail\nAt path %s!', 'w', True)
        exit(1)


def check_gradle_wrapper(local):
    if not check_dir_or_file_is_exist(local):
        log_printer('Not found path: %s\exit 1' % local, 'e', True)
        exit(1)
    gradlew_tag = 'gradlew'
    if is_platform_windows():
        gradlew_tag = 'gradlew.bat'
    gradlew_path = os.path.join(local, gradlew_tag)
    if not check_dir_or_file_is_exist(gradlew_path):
        log_printer('Not found %s at Path: %s\exit 1' % (gradlew_tag, local), 'e', True)
        exit(1)
    if not is_platform_windows():
        gradlew_exec = 'chmod +x %s' % gradlew_tag
        exec_cli(gradlew_exec, local, out_of_time_default, True)
    return gradlew_tag


def run_single_gradle_task(local, gradlew_tag, task, info=False, refresh_dependencies=False):
    if is_platform_windows():
        cmd_build = '%s %s' % (gradlew_tag, task)
    else:
        cmd_build = './%s %s' % (gradlew_tag, task)
    if refresh_dependencies:
        cmd_build = '%s --refresh-dependencies' % cmd_build
    if info:
        cmd_build = '%s --info' % cmd_build
    res = exec_cli(cmd_build, local, out_of_time_build)
    if res:
        log_printer('\n=== project build success ===\nBuild cli:%s\n=== project build success ===\n' % cmd_build, 'i',
                    True)
        return True
    else:
        log_printer('\n=== project build fail ===\nBuild cli:%s\n=== project build fail ===\n' % cmd_build, 'w', True)
        return False


def build_android_project_at_module_by_task(local, tasks):
    gradlew_tag = check_gradle_wrapper(local)
    if len(tasks) < 1:
        log_printer('You are not set any task please check config \exit 1\n', 'e', True)
        exit(1)
    for task in tasks:
        module_task = task['module']
        task_task = task['task']
        if module_task == 'projectRoot':
            task_unit = '%s' % task_task
        else:
            task_unit = ':%s:%s' % (module_task, task_task)
        if 'need_refresh_depend' in task.keys():
            res_task = run_single_gradle_task(local, gradlew_tag, task_unit, is_verbose, True)
        else:
            res_task = run_single_gradle_task(local, gradlew_tag, task_unit, is_verbose)
        if not res_task:
            return False
        else:
            continue


def auto_clean_build_project(local=str):
    if not check_dir_or_file_is_exist(local):
        log_printer('Not found path: %s\exit 1' % local, 'e', True)
        exit(1)
    change_files_write(local)
    time.sleep(1)
    shutil.rmtree(local, True)
    time.sleep(1)
    log_printer('Auto clean success path: %s' % local, 'i', True)


def filter_project_config(project, build_path=str):
    name_p = project['name']
    git_url_p = project['git_url']
    local_p = project['local']
    local_p = os.path.join(build_path, local_p)
    branch_p = project['branch']
    tag_p = project['tag']
    version_name_p = project['version_name']
    version_code_p = project['version_code']
    tasks_p = project['tasks']
    mode_p = project['mode']
    auto_clean_p = project['auto_clean']
    git_clone_project_by_branch_and_try_pull(git_url_p, local_p, branch_p)
    check_project_version_info_at_gradle_properties(local_p, version_name_p, version_code_p)

    task_res = build_android_project_at_module_by_task(local_p, tasks_p)
    if not task_res:
        exit(1)
    if auto_clean_p != 0:
        auto_clean_build_project(local_p)


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print "You must input params or see -h"
        exit(1)
    check_p = str(sys.argv[1])
    if not check_p.startswith('-'):
        print 'You params is error please see -h'
        exit(1)
    parser = optparse.OptionParser('Usage %prog ' + '-i -v')
    parser.add_option('-v', '--verbose', dest='v_verbose', action="store_true",
                      help="see verbose", default=False)
    parser.add_option('--config', dest='config', type="string",
                      help="build config json file if not set use run path build.json"
                      , metavar="build.json")
    parser.add_option('-c', '--clean', dest='c_clean', action="store_true",
                      help="clean you set build_path ", default=False)
    parser.add_option('-f', '--force', dest='f_force', action="store_true",
                      help="force build not set check", default=False)
    (options, args) = parser.parse_args()
    logger = init_logger_by_time(this_tag)
    if options.v_verbose:
        is_verbose = True
    config_file_path = os.path.join(root_run_path, "build.json")
    if options.config:
        config_file_path = options.config
    log_printer('Load config path at: %s\n' % config_file_path, 'i', True)
    if options.c_clean:
        js = read_json_file(config_file_path)
        build_path = js['build_path']
        build_path = os.path.join(root_run_path, build_path)
        change_files_write(build_path)
        time.sleep(1)
        shutil.rmtree(build_path, True)
        time.sleep(1)
        log_printer('Clean success : %s' % build_path, 'i', True)
        exit(0)
    if options.f_force:
        read_json_config(config_file_path)
