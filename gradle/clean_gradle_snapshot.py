# coding=utf-8

import json
import os
import sys
import platform
import stat
import time
import inspect
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
this_tag = 'clean_'

"""
自动清空日志的时间差，默认为一周
"""
out_of_time_log_auto_clean = 60 * 60 * 24 * 7

gradle_file_2_1_path = os.path.join(os.path.expandvars('$HOME'), '.gradle', 'caches', 'modules-2', 'files-2.1')


def init_logger(first_tag, sec_tag=str):
    global logger
    log_file = first_tag + sec_tag + '.log'
    log_path = check_current_log_path_and_auto_clean()
    log_path_join = os.path.join(log_path, log_file)
    handler = logging.handlers.RotatingFileHandler(log_path_join, maxBytes=1024 * 1024, backupCount=5)
    fmt = '%(asctime)s - %(filename)s:%(lineno)s - %(name)s - %(levelname)s - %(message)s'
    formatter = logging.Formatter(fmt)
    handler.setFormatter(formatter)
    logger = logging.getLogger(str(getpass.getuser()))
    logger.addHandler(handler)
    logger.setLevel(logging.DEBUG)
    return logger


def check_current_log_path_and_auto_clean():
    """
    自动在脚本的运行目录创建 log 子目录，并检查日志文件，自动删除一周前的日志
    :return:
    """
    log_path = os.path.join(current_file_directory(), 'log')
    if not check_dir_or_file_is_exist(log_path):
        os.makedirs(log_path)
    else:
        check_time = time.time()
        for walk_dir, walk_folder, walk_file in os.walk(log_path):
            for f in walk_file:
                if f.endswith('.log'):
                    check_path_join = os.path.join(walk_dir, f)
                    m_time = os.path.getmtime(check_path_join)
                    if check_time - m_time > out_of_time_log_auto_clean:
                        os.remove(check_path_join)
                        print 'auto_clean log file : %s' % check_path_join
    return log_path


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


def current_file_directory():
    path = os.path.realpath(sys.path[0])  # interpreter starter's path
    if os.path.isfile(path):  # starter is excutable file
        path = os.path.dirname(path)
        return os.path.abspath(path)  # return excutable file's directory
    else:  # starter is python script
        caller_file = inspect.stack()[1][1]  # function caller's filename
        return os.path.abspath(os.path.dirname(caller_file))  # return function caller's file's directory


def check_dir_or_file_is_exist(abs_path=str):
    return os.path.exists(abs_path)


def change_files_write(path=str):
    # type: (str) -> None
    for root, dirs, files in os.walk(path):
        for name in files:
            os.chmod(os.path.join(root, name), stat.S_IWRITE)
    logger.info('change change_files_write success')


def del_dot_head_files(dot_path=str):
    try:
        for root, dirs, files in os.walk(dot_path):
            for name in files:
                if name.startswith("."):
                    os.remove(os.path.join(root, name))
        logger.info("delete path " + dot_path + " success!")
    except Exception, e:
        logger.error(e)
        print e


def sorted_dict_values_to_list(s_dict):
    keys = s_dict.keys()
    keys.sort()
    return [s_dict[key] for key in keys]


def check_user_gradle_path():
    log_printer('try to find this user gradle file 2.1 path %s\n' % gradle_file_2_1_path, 'i', True)
    return check_dir_or_file_is_exist(gradle_file_2_1_path)


def clean_useless_gradle_catch_snapshot():
    """
    寻找默认配置的gradle 缓存中，除去最后一次修改的SNAPSHOT
    :return:
    """
    if check_user_gradle_path():
        snapshot_path_list = find_out_snapshot_path_list()
        for snapshot_path in snapshot_path_list:
            for walk_dir, walk_folder, walk_file in os.walk(snapshot_path):
                now_folder = {}
                for d in walk_folder:
                    snapshot_hash_path = os.path.join(walk_dir, d)
                    m_time = os.path.getmtime(snapshot_hash_path)
                    now_folder[m_time] = snapshot_hash_path
                if len(now_folder) > 0:
                    new_sort = sorted_dict_values_to_list(now_folder)
                    for path in new_sort[0: -1]:
                        shutil.rmtree(path)
                        log_printer('remove useless snapshot at path\n-> %s' % path, 'i', True)
    else:
        log_printer('can not found gradle catch folder exit', 'e', True)
        exit(1)


def find_out_snapshot_path_list():
    snapshot_path_arr = []
    for walk_dir, walk_folder, walk_file in os.walk(gradle_file_2_1_path):
        for d in walk_folder:
            if d.endswith('-SNAPSHOT'):
                snapshot_path = os.path.join(walk_dir, d)
                snapshot_path_arr.append(snapshot_path)
    return snapshot_path_arr


def clean_old_gradle_catch_snapshot():
    pass


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
    parser.add_option('-c', '--cleanOld', dest='c_cleanOld', action="store_true",
                      help="clean you set build_path ", default=False)
    parser.add_option('-u', '--uselessClean', dest='u_uselessClean', action="store_true",
                      help="clean you set build_path last modification", default=False)
    parser.add_option('-f', '--force', dest='f_force', action="store_true",
                      help="force build not set check", default=False)
    (options, args) = parser.parse_args()
    logger = init_logger_by_time(this_tag)
    if options.v_verbose:
        is_verbose = True
    if options.u_uselessClean:
        try:
            clean_useless_gradle_catch_snapshot()
        except Exception, e:
            log_printer('just some error, please check %s' % str(e))
    if options.c_cleanOld:
        clean_old_gradle_catch_snapshot()
