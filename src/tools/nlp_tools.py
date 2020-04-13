from afinn import Afinn
import random
import nltk
import nltk.tokenize
from nltk.corpus import state_union
from nltk.corpus import stopwords
from nltk.stem import PorterStemmer
from nltk.tokenize import RegexpTokenizer
from src.tools import file_tools as ft


afin = Afinn()
def sentiment(text):
    words = clean_text_token(text)
    document = words_to_document(words)
    score = afin.score(document)
    return score


def sentence_tokenize(document):
    sentences = nltk.tokenize.sent_tokenize(document)
    return sentences


def word_tokenize(document):
    words = nltk.tokenize.word_tokenize(document)
    return words


def frequency_of_words(words):
    return nltk.FreqDist(words)


def words_to_document(words):
    return " ".join(words)


punctuation_tokenizer = RegexpTokenizer(r'\w+')
def word_tokenize_remove_punctuation(document):
    word_tokens = punctuation_tokenizer.tokenize(document)
    return word_tokens


stop_words = set(stopwords.words('english'))


def filter_stop_words(words):
    filtered_words = [w for w in words if w not in stop_words]
    return filtered_words


ps = PorterStemmer()
def stem_of_words(words):
    w_return = []
    for w in words:
        w_return.append(ps.stem(w))
    return w_return


def clean_text_token(text):
    document = text.lower()
    # words = word_tokenize(document)
    words = word_tokenize_remove_punctuation(document)
    words = filter_stop_words(words)
    words = stem_of_words(words)
    return words


def words_to_document(words):
    return " ".join(words)


def count(text, features):
    num = [word for word in text if word in features]
    return len(num)


def get_sentiment_by_score(score):
    if score > 0:
        sentiment = 'pos'
    elif score < 0:
        sentiment = 'neg'
    else:
        # if score = 0, sentiment = neutral
        sentiment = 'neu'
    return sentiment


def reverse_sentiment_to_score(sentiment):
    score = 0
    if sentiment == 'pos':
        score = 1
    elif sentiment == 'neg':
        score = -1
    else:
        # if sentiment = 'neu', score = 0
        score = 0
    return score


def set_sentiment_to_texts(texts, positive, negative):
    documents = []
    pos = 0
    neg = 0
    neu = 0
    for text in texts:
        text_token = clean_text_token(text)
        pos_num = count(text_token, positive)
        neg_num = count(text_token, negative)
        score = pos_num - neg_num
        sentiment = get_sentiment_by_score(score)
        if score > 0:
            pos = pos + 1
        elif score < 0:
            neg = neg + 1
        else:
            neu = neu + 1
        documents.append((text, sentiment))
    print('document category:')
    print('pos:' + str(pos))
    print('neg:' + str(neg))
    print('neu:' + str(neu))
    return documents

