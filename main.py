from src import twitter
from src.tools import file_tools as ft
from src.tools import nlp_tools as nt


def add_zero(i):
    if i < 10:
        return "0" + str(i)
    else:
        return str(i)


def download_tweet(start_day=1, end_day=31, start_index=0, end_index=23, folder="2020-03"):
    basic_path = ft.join_path(ft.basic_path, "dataset", folder)
    for i in range(start_day, end_day + 1):
        s_day = add_zero(i)
        save_path = ft.join_path(basic_path, "coronavirus-tweet-%s-%s.csv" % (folder, s_day))
        for j in range(start_index, end_index + 1):
            file_name = "coronavirus-tweet-id-%s-%s-%s.txt" % (folder, add_zero(i), add_zero(j))
            file_path = ft.join_path(basic_path, file_name)
            twitter.download_by_ids(tweet_path=file_path, save_path=save_path)


def summary_tweet_sentiment(start_day=1, end_day=31, folder="2020-03"):
    basic_path = ft.join_path(ft.basic_path, "dataset", folder)
    sum_path = ft.join_path(basic_path, "coronavirus-tweet-summary.csv")
    ft.append_csv(["date", "score", "rs", "fs"], sum_path)
    for i in range(start_day, end_day + 1):
        s_day = add_zero(i)
        file_path = ft.join_path(basic_path, "coronavirus-tweet-%s-%s.csv" % (folder, s_day))
        df = ft.load_csv(file_path)
        df["rs"] = df["retweet_count"] * df["score"]
        df["fs"] = df["favorite_count"] * df["score"]
        temp = df[["score", "rs", "fs"]].mean(axis=0, skipna=True)
        row = [df["date"][1], temp["score"], temp["rs"], temp["fs"]]
        ft.append_csv(row, sum_path)


if __name__ == '__main__':
    # test
    # ids_path = ft.join_path(ft.basic_path, 'ids.txt')
    # twitter.load_by_ids(tweet_path=ids_path)

    # download tweet
    # download_tweet(start_day=1, end_day=10, start_index=0, end_index=1, fold="2020-04")

    # calculate
    summary_tweet_sentiment(start_day=1, end_day=10, folder="2020-04")
    pass
