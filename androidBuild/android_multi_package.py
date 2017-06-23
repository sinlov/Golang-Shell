# coding=utf-8
import json
import os
import sys
import stat

import logging
import logging.handlers
import optparse

import time

__author__ = 'sinlov'

reload(sys)
sys.setdefaultencoding('utf-8')

is_verbose = False
run_path = os.getcwd()
this_tag = 'android_multi_build_'

android_build_path = 'build'
android_project_path = "OSMobile"
android_build_branch = "main-develop"
android_build_module = "app"
android_build_task = "OsCiTest"


def find_now_time_format(format_time=str):
    """
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
    :param format_time:
    :return:
    """
    return time.strftime(format_time, time.localtime(time.time()))


def init_logger(first_tag, sec_tag=str):
    global logger
    log_file = first_tag + sec_tag + '.log'
    handler = logging.handlers.RotatingFileHandler(log_file, maxBytes=1024 * 1024, backupCount=5)
    fmt = '%(asctime)s - %(filename)s:%(lineno)s - %(name)s - %(levelname)s - %(message)s'
    formatter = logging.Formatter(fmt)
    handler.setFormatter(formatter)
    logger = logging.getLogger('sinlov')
    logger.addHandler(handler)
    logger.setLevel(logging.DEBUG)
    return logger


def init_logger_by_time(tag=str):
    return init_logger(tag, find_now_time_format('%Y_%m_%d_%H_%M_%S'))


def log_printer(msg, lev=str, must=False):
    if is_verbose or must:
        print msg
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


def check_dir_is_exist(dir_path=str):
    return os.path.exists(dir_path)


def read_json_config(json_path=str):
    if not os.path.exists(json_path):
        log_printer("can not find json config, exit!", 'e', True)
        exit(1)
    try:
        with open(json_path, 'r') as load_js:
            js = json.load(load_js)
            build_path = js['build_path']
            build_path = os.path.join(run_path, build_path)
            if not check_dir_is_exist(build_path):
                os.mkdir(build_path)
            build_projects = js['build_projects']
            for project in build_projects:
                filter_project_config(project, build_path)
    except Exception, e:
        log_printer('Read json config file: ' + json_path + '\n' + str(e) + '\nError, exit!', 'e', True)
        exit(1)


def filter_project_config(project, build_path=str):
    name_p = project['name']
    git_url_p = project['git_url']
    local_p = project['local']
    local_p = os.path.join(build_path, local_p)
    branch_p = project['branch']
    tag_p = project['tag']
    module_p = project['module']
    task_p = project['task']
    mode_p = project['mode']
    git_clone_project(git_url_p, local_p, branch_p)


def change_files_write(path=str):
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


def git_clone_project(project_url=str, local_path=str, branch=str):
    cmd_line = 'git clone %s -b %s %s' % (project_url, branch, local_path)
    output = os.system(cmd_line)
    if output != 0:
        log_printer(cmd_line + ' clone project error please check ' + str(output), 'e', True)
    if not check_dir_is_exist(local_path):
        str_error = '\n===\nClone project error please check\n%s\n===\n' % cmd_line
        log_printer(str_error, 'e', True)
    else:
        str_info = "\n===\nClone project finish\n%s\n===\n" % cmd_line
        log_printer(str_info, 'i', True)


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print "You must input params or see -h"
        exit(1)
    check_p = str(sys.argv[1])
    if not check_p.startswith('-'):
        print 'You params is error please see -h'
        exit(1)
    logger = init_logger_by_time(this_tag)
    parser = optparse.OptionParser('Usage %prog ' + '-i -v')
    parser.add_option('-v', '--verbose', dest='v_verbose', action="store_true",
                      help="see verbose", default=False)
    parser.add_option('--config', dest='config', type="string",
                      help="build config json file if not set use run path build.json"
                      , metavar="build.json")
    (options, args) = parser.parse_args()
    if options.v_verbose:
        is_verbose = True
    config_file_path = os.path.join(run_path, "build.json")
    if options.config:
        config_file_path = options.config
    log_printer('load config path at ' + config_file_path)
    read_json_config(config_file_path)
