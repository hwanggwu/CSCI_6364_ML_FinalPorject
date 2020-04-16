import json
import pandas as pd
import os
import struct
import csv
import numpy as np
import _pickle as pickle


# get cwd
def get_cwd():
    return os.getcwd()


# join path
def join_path(*args):
    path = ''
    for v in args:
        path = os.path.join(path, v)
    return path


# root path.  os.path.pardir = ..
# basic_path = join_path(get_cwd(), os.path.pardir, 'data')
basic_path = join_path(get_cwd(), 'resource')


# judge whether file exist
def is_exist(path):
    flag = os.path.exists(path)
    return flag


def load_json(*args):
    with open(join_path(basic_path, *args), 'r') as load_f:
        load_dict = json.load(load_f)
        return load_dict


# load English dictionary
def load_words():
    with open(join_path(basic_path, 'dictionary', 'words_alpha.txt')) as word_file:
        valid_words = set(word_file.read().split())
    return valid_words


def load_dict_by_line(file_name):
    file = open(join_path(basic_path, 'dictionary', file_name), "r")
    return file


def save_pickle(file, path):
    s_classifier = open(path, 'wb')
    pickle.dump(file, s_classifier)
    s_classifier.close()


def load_pickle(path):
    classifier_f = open(path, 'rb')
    classifier = pickle.load(classifier_f)
    classifier_f.close()
    return classifier


def save_csv(df, path):
    df.to_csv(path)


def append_csv(row, path):
    with open(path, 'a+', newline="") as f:
        csv_write = csv.writer(f)
        csv_write.writerow(row)


# load
def load_csv(path, trans=False):
    df = pd.read_csv(path)
    # date document
    if trans:
        df = np.array(df)
    return df
