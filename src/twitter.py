from tweepy import Stream
from tweepy import OAuthHandler
from tweepy.streaming import StreamListener
import json
import pandas as pd
import matplotlib.pyplot as plt
# import matplotlib.animation as animation
# from matplotlib import style
from datetime import datetime
from src.tools import file_tools as ft
from src.tools import nlp_tools as nt
from twarc import Twarc

#
# # consumer key, consumer secret, access token, access secret.
access_dict = ft.load_json('access', 'twitter_access.json')
ckey = access_dict['ckey']
csecret = access_dict['csecret']
atoken = access_dict['atoken']
asecret = access_dict['asecret']

t = Twarc(ckey, csecret, atoken, asecret)


def load_by_ids(tweet_path, save_path=None):

    df = pd.DataFrame(columns=['tweet_id', 'date', 'retweet_count', 'favorite_count', 'score'])
    if save_path is not None:
        is_exist = ft.is_exist(save_path)
        if not is_exist:
            ft.save_csv(df, save_path)

    for tweet in t.hydrate(open(tweet_path)):

        tweet_id = tweet.get('id', 0000000000000000000)
        created_at = tweet.get('created_at', 'Sat Jan 01 01:00:00 +0000 2000')
        date = datetime.strptime(created_at, '%a %b %d %H:%M:%S %z %Y')
        re_status = tweet.get('retweeted_status', {})
        retweet_count = re_status.get('retweet_count', 0)
        favorite_count = re_status.get('retweeted_status', 0)
        full_text = tweet.get('full_text', '')
        score = nt.sentiment(full_text)

        row = {'tweet_id': tweet_id, 'date': date, 'retweet_count': retweet_count,
               'favorite_count': favorite_count, 'score': score}
        # df = df.append(row, ignore_index=True)
        print(row)
        if save_path is not None:
            ft.append_csv(row, save_path)


class listener(StreamListener):

    def on_data(self, data):
        all_data = json.loads(data)

        tweet = all_data["text"]
        # sentiment_value, confidence = nc.sentiment(tweet, platform=nt.FINANCIAL_SOURCE_TWITTER)
        # print(tweet, sentiment_value, confidence)
        print(tweet)

        # if confidence * 100 >= 80:
        #     output = open(ft.join_path(ft.basic_path, 'corpus', "twitter-out.txt"), "a")
        #     output.write(sentiment_value)
        #     output.write('\n')
        #     output.close()

    def on_error(self, status):
        print(status)


def download_twitter():
    auth = OAuthHandler(ckey, csecret)
    auth.set_access_token(atoken, asecret)

    twitterStream = Stream(auth, listener())
    twitterStream.filter(track=["google"])
#
#
# style.use("ggplot")
#
# fig = plt.figure()
# ax1 = fig.add_subplot(1, 1, 1)
#
#
# def animate(i):
#     pullData = open("twitter-out.txt", "r").read()
#     lines = pullData.split('\n')
#
#     xar = []
#     yar = []
#
#     x = 0
#     y = 0
#
#     for l in lines[-200:]:
#         x += 1
#         if "pos" in l:
#             y += 1
#         elif "neg" in l:
#             y -= 1
#
#         xar.append(x)
#         yar.append(y)
#
#     ax1.clear()
#     ax1.plot(xar, yar)
#
# def plot_twitter():
#     ani = animation.FuncAnimation(fig, animate, interval=1000)
#     plt.show()
#
#
#
