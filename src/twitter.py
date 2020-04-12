# from tweepy import Stream
# from tweepy import OAuthHandler
# from tweepy.streaming import StreamListener
# import json
# import matplotlib.pyplot as plt
# import matplotlib.animation as animation
# from matplotlib import style
# import time
# from classifer import nlp_classifier as nc
from src.tools import file_tools as ft
# from tools import nlp_tools as nt
from twarc import Twarc


#
# # consumer key, consumer secret, access token, access secret.
access_dict = ft.load_json('access', 'twitter_access.json')
ckey = access_dict['ckey']
csecret = access_dict['csecret']
atoken = access_dict['atoken']
asecret = access_dict['asecret']

t = Twarc(ckey, csecret, atoken, asecret)

def load_by_ids(path):
    for tweet in t.hydrate(open(path)):
        print(tweet["full_text"])
#
#
# class listener(StreamListener):
#
#     def on_data(self, data):
#
#         all_data = json.loads(data)
#
#         tweet = all_data["text"]
#         # sentiment_value, confidence = nc.sentiment(tweet, platform=nt.FINANCIAL_SOURCE_TWITTER)
#         # print(tweet, sentiment_value, confidence)
#         print(tweet)
#
#         # if confidence * 100 >= 80:
#         #     output = open(ft.join_path(ft.basic_path, 'corpus', "twitter-out.txt"), "a")
#         #     output.write(sentiment_value)
#         #     output.write('\n')
#         #     output.close()
#
#     def on_error(self, status):
#         print(status)
#
# def download_twitter():
#     auth = OAuthHandler(ckey, csecret)
#     auth.set_access_token(atoken, asecret)
#
#     twitterStream = Stream(auth, listener())
#     twitterStream.filter(track=["google"])
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
