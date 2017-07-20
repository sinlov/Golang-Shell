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
this_tag = 'log_jenkins_download_last_artifact_'

"""
执行默认超时时间 60 * 1 秒
"""
out_of_time_default = 60 * 1


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


def time_stamp_mark():
    """
    Time mark %y.%m.%d.%M.%S
    :return: time string
    """
    now = datetime.datetime.now()
    return now.strftime('%y.%m.%d.%M.%S')


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


def auto_clean_build_project(local=str):
    if not check_dir_or_file_is_exist(local):
        log_printer('Not found path: %s\exit 1' % local, 'e', True)
        exit(1)
    change_files_write(local)
    time.sleep(1)
    shutil.rmtree(local, True)
    time.sleep(1)
    log_printer('Auto clean success path: %s' % local, 'i', True)


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


def get_params_none_to_not_find_value(params_dir, param_key, not_find_value):
    """
    :type params_dir: Any
    :type param_key: str
    :type not_find_value: Any
    """
    if param_key in params_dir:
        return params_dir[param_key]
    else:
        log_printer('not find key [ %s ] just set [ %s ]' % (param_key, not_find_value), 'i', False)
        return not_find_value


def check_params_default(params_dir, param_key, default_value):
    """
    :type params_dir: Any
    :type param_key: str
    :type default_value: Any
    """
    if param_key in params_dir:
        return params_dir[param_key]
    else:
        log_printer('not set key [ %s ] default [ %s ]' % (param_key, default_value), 'i', True)
        return default_value


def check_params_none_exit(config_dir, param_key):
    """
    :type config_dir: Any
    :type param_key: str
    """
    if param_key in config_dir:
        return config_dir[param_key]
    else:
        log_printer('not set [ %s ] exit!' % param_key, 'e', True)
        exit(1)


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
            str_err = "cmd_line success: %s\n%s" % (cmd_string, str(command_out.stdout.read()))
            command_out.stdout.close()
            log_printer(str_err, 'i', True)
            return True
        else:
            str_out = "cmd_line fail out: %s\n%s" % (cmd_string, str(command_out.stdout.read()))
            str_err = "cmd_line fail: %s\n%s" % (cmd_string, str(command_out.stderr.read()))
            command_out.stdout.close()
            command_out.stderr.close()
            log_printer('%s\n%s' % (str_out, str_err), 'e', True)
            return False
    except Exception, e:
        log_printer('cmd_line %s\nError info %s' % (cmd_string, str(e)), 'e', True)
        return False


def read_json_config(config_file):
    # type: (str) -> None
    if not os.path.exists(config_file):
        log_printer("can not find json config, exit!", 'e', True)
        exit(1)
    try:
        with open(config_file, 'r') as load_js:
            config_js = json.load(load_js)
            js_download_path = check_params_none_exit(config_js, 'download_path')
            js_work_path = os.path.join(root_run_path, js_download_path)
            if not check_dir_or_file_is_exist(js_work_path):
                os.mkdir(js_work_path)
            js_download_projects = check_params_none_exit(config_js, 'download_projects')
            for project in js_download_projects:
                filter_project_config(project, js_work_path)
    except Exception, e:
        log_printer('Read json config file: %s\n%s\nError, exit!' % (config_file, str(e)), 'e', True)
        exit(1)


def download_jenkins_build_artifact(build_type, build_num, jc_work_path, job_url_base):
    if not build_type == 'artifact':
        log_printer('[ build_history ] not set artifact exit', 'e', True)
        exit(1)
    if build_num == 0:
        build_code = 'lastSuccessfulBuild'
    else:
        build_code = str(build_num)
    download_full_path = '%s/%s/artifact/*zip*/archive.zip' % (job_url_base, build_code)
    new_file_name = '%s-%s.zip' % (build_code, time_stamp_mark())
    log_printer('-> === just download full url\n%s\nNew name %s\n\n-> ===' % (download_full_path, new_file_name), 'i', True)


def filter_project_config(js_project, work_path):
    j_name = check_params_none_exit(js_project, 'name')
    jc_work_path = os.path.join(work_path, j_name)
    if not check_dir_or_file_is_exist(jc_work_path):
        os.mkdir(jc_work_path)
        log_printer('just make dir %s for download' % jc_work_path, 'i', True)
    jenkins_url = check_params_none_exit(js_project, 'jenkins_url')
    jenkins_group = check_params_none_exit(js_project, 'jenkins_group')
    job_url_base = '%s/view/%s/%s' % (jenkins_url, jenkins_group, j_name)
    auto_clean = check_params_default(js_project, 'auto_clean', 0)
    build_history = get_params_none_to_not_find_value(js_project, 'build_history', '')
    args = get_params_none_to_not_find_value(js_project, 'args', '')
    if not build_history == '':
        for build in build_history:
            build_num = check_params_none_exit(build, 'build_num')
            build_type = check_params_none_exit(build, 'build_type')
            download_jenkins_build_artifact(build_type, build_num, jc_work_path, job_url_base)
    else:
        log_printer('build_history set is error exit', 'e', True)
        exit(1)
    if auto_clean != 0:
        auto_clean_build_project()


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
                      help="build config json file if not set use run path config.json"
                      , metavar="build.json")
    parser.add_option('-c', '--clean', dest='c_clean', action="store_true",
                      help="clean you set build_path ", default=False)
    parser.add_option('-f', '--force', dest='f_force', action="store_true",
                      help="force build not set check", default=False)
    (options, args) = parser.parse_args()
    logger = init_logger_by_time(this_tag)
    if options.v_verbose:
        is_verbose = True
    config_file_path = os.path.join(root_run_path, "config.json")
    if options.config:
        config_file_path = options.config
    log_printer('Load config path at: %s\n' % config_file_path, 'i', True)
    if options.c_clean:
        js = read_json_file(config_file_path)
        download_path = check_params_none_exit(js, 'download_path')
        work_path = os.path.join(root_run_path, download_path)
        change_files_write(work_path)
        time.sleep(1)
        shutil.rmtree(work_path, True)
        time.sleep(1)
        log_printer('Clean success : %s' % work_path, 'i', True)
        exit(0)
    if options.f_force:
        read_json_config(config_file_path)
