from src import twitter
from src.tools import file_tools as ft
from src.tools import nlp_tools as nt


def format_name(i, j):
    if i < 10:
        s1 = "0" + str(i)
    else:
        s1 = str(i)
    if j < 10:
        s2 = "0" + str(j)
    else:
        s2 = str(j)
    name = "coronavirus-tweet-id-2020-03-%s-%s.txt" % (s1, s2)
    return name


if __name__ == '__main__':

    # test
    # ids_path = ft.join_path(ft.basic_path, 'ids.txt')
    # twitter.load_by_ids(tweet_path=ids_path)

    # download tweet
    basic_path = ft.join_path(ft.basic_path, "dataset", "2020-03")
    for i in range(1, 32):
        for j in range(0, 24):
            name = format_name(i, j)
            file_path = ft.join_path(basic_path, "coronavirus-tweet-id-2020-03-01-00.txt")
            twitter.load_by_ids(tweet_path=file_path)
