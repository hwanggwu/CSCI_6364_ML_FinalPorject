# Prediction model of CoronaVirus (COVID-19) at New York City

Ming Gong and Henian Wang will expore the prediction model of novel coronavirus (COVID-19) at New York City . Mathematical statistics and support vectorregression analysis are used for comprehensive prediction analysis. 
   
We plans to use our machine learning knowledge to get data from China’s cities (expecially Wuhan, the origin of the coronavirus), and use the features such as medical resources (Hospital beds per 1,000 people), population density, protective suits number, face musk number to fit a regression model that predict the coronovirus spread activitiy (number of patient who tested postive for COVID-19).
    
The analysis gives the short and medium term future data and change trend curve, for analysis and reference of relevant personnel, and the model could be a instructural tool for avoid more spread of coronavirus at other cities. 

![](RackMultipart20200522-4-1n00qm3_html_ab49ea7f76fb21c8.gif) ![](RackMultipart20200522-4-1n00qm3_html_b80e048dca76330e.gif)

_Ming Gong &amp;_ _Henian Wang_

_CSCI 6364 Machine Learning_ _|_ _April 26 2020_

![](RackMultipart20200522-4-1n00qm3_html_f873d03f3b401db.gif)

# _A prediction model of COVID-19 confirmed cases in the U.S. based on NLP_

#

1. **Introduction**

In 2020, an outbreak of a pneumonia infectious disease characterized by fever, dry cough, and even taste blindness symptoms spread all over the world. The U.S., as the most affected country, has been influenced by 900,000 people, killed 55,000 people. COVID-19 is now the worst pandemic since the 21st century, and it has become a challenge for every human being fighting with the coronavirus. Since there are no standard treatments for COVID-19, it is important to avoid infection or further spreading. To provide predictive information for coronavirus, we decided to build a prediction model of coronavirus cases in the U.S.. We wish to find when the pandemic will come into the turning point, and how many people the pandemic will finally infect in the U.S..

Depending on the current increasing number of cases and an optimistic hypothesis that people will more and more positive to this epidemic, our model shows that the turning point of this pandemic in the U.S. will be in May 2020, and the finally infectious population will be around 1.5 million. Our model is combined with the traditional epidemic model and Natural Language Processing. By using the Twitter Sentiment analysis, we adjusted the parameters in our model.

1. **Method**
  1. **Data collection**

We collected data from two main sources, and they are found on the internet.

The first dataset is the Novel Corona Virus (COVID-19) epidemiological data from humdata.org. The data is collected from 22 January 2020 and is compiled by the Johns Hopkins University Center for Systems Science and Engineering from various sources from all over the world. The dataset includes fields like Province, Country, confirmed, and recovered cases. We download the CSV files which include the daily confirmed cases in the U.S..

The second dataset is the Twitter corpus. The Twitter Developer can use the Twitter API to analyze the contents by NLP. We used the collected data from Emily Chen, who provides the tweet id related to coronavirus in GitHub. He leveraged Twitter&#39;s streaming API to follow specified accounts and collect real-time tweets that mention specific keywords. Figure 1 shows the part of the keywords by which the corpus is collected.

![image](/resource/dataset/picture/1.png)

Figure 1. Coronavirus Keywords sample

Figure 2 shows the data collected from twitter by tweet id. Retweet\_count is the forwarding number of each twitter. Favorite\_count is the likes number of each twitter. The score is the sentiment score calculated by afinn package.

![image](/resource/dataset/picture/2.png)

Figure 2. the data of each tweet

Figure 3 shows the statistical data which is grouped by day. The score is the average of the sentiment score from each day. rs is the average of the product of each twitter&#39;s sentiment score and its retweet\_count. fs is the average of the product of each twitter&#39;s sentiment score and its favorite\_count.

![image](/resource/dataset/picture/3.png)

Figure 3. the summary of every day

If twitter has a high forwarding number and likes number, this twitter should have a bigger influence than twitter which has a low forwarding number and likes number. Therefore, we use rs and fs to describe people&#39;s daily sentiment instead of the average score. Additionally, from figure 4, there is an obvious linear relationship between rs and fs, so we just choose one of them to make prediction. In this experiment, we choose fs.

![image](/resource/dataset/picture/4.png)

Figure 4. the scatter points of the rs and fs

Figure 5 shows the time series of fs after scaling. In the beginning, the fs is less than zero. With time goes by, the fs is closed to zero and become more and more positive. This meets our assumption that people will more and more positive about this epidemic.

![image](/resource/dataset/picture/5.png)

Figure 5. the time series of fs after scaled

  1. **Traditional Epidemic Model**

The traditional epidemic model is based on a basic infectious mechanism. In this model, the defined variables include Incubation interval(M): the time interval of two infectious generations, the basic infection rate(R0): the people which one confirmed patient can infect, and generation(n): n = day mod Incubation interval(M).

![image](/resource/dataset/picture/6.png)

Figure 6. The traditional epidemic model

In the first generation, the number of confirmed patients is 1. In the next generation, this confirmed patient can infect R0 people, so in the second generation, the total confirmed patients are 1 + 1\*R0. By that analogy, in the n generation, the total confirmed patients show as formula (1).

In each generation, the increased confirmed patients are . The incubation interval is M, and we assume that the number of people in each interval grows every day at the same rate, so the daily increase confirmed patients show as formula (2).

  1. **NLP (Twitter Sentiment Analysis) optimization**

We assume the initial R0 is 3 and the initial M is 4 to do a prediction by the traditional epidemic model. From the figure 7, the growth rate of the prediction by the traditional epidemic model is much faster than the growth rate of the actual confirmed patients. The traditional epidemic model is exponential growth, but the growth rate cannot be exponential growth in the real world.

There are two ways to control the growth rate of the traditional epidemic model: adjust the base and the exponent part of the formula (2). We wish the sentiment score from twitter can adjust the initial R0. When the sentiment score is positive, which means most people think the situation is good, we wish the base can decrease; when the sentiment score is negative, which means most people think the situation is bad, we wish the base can increase; when the sentiment score is zero, we wish the base can equal to R0. If we change the denominator into 2\*R0 and the parameter t into fs, the sigmoid function can meet our requirements very well. Formula (4) shows the traditional epidemic model after changing the base.

![image](/resource/dataset/picture/7.png)

Figure 7. the time series of the prediction by the traditional epidemic model(the blue line) and actual confirmed patients (the red line)

By using the adjusted model, we re-make the prediction. The prediction shows as figure 8.

From figure 8, the growth rate is controlled well by fs, and the prediction of the adjusted model is closed to the actual confirmed patients. However, there are some places that have large jumps due to the obvious fluctuation of the fs. We wish the curve can be smoother and more closed to the actual confirmed patient. Therefore, we should adjust the exponent part of the formula (2).

n is equal to day mod M and we wish n decreases when day increases, so we set . When day is closed to the infinite, the n will close to the , that prevents the exponent become too large. Additionally, we set , that means as the day increases, the daily increased patients will decrease. Formula (5) shows the traditional epidemic model after changing the base and exponent.

![image](/resource/dataset/picture/8.png)

Figure 8. the time series of the prediction by the adjusted(1) traditional epidemic model(the blue line) and actual confirmed patients (the red line)

The day, actual daily increases, and fs are known, so we can use the least square method to calculate the k and m. Finally, we get the k=0.0350 and m=4.8454. If day equal to 0, the equal to which is very closed to the . This coincidence shows the initial value of M which we choose fits the actual data well.

1. **Result**

We tested our prediction model with the actual data from 03/01 to 04/10. From figure 9, the results show that the two curves have been fitting in shape.

Because our model depends on the fs and we cannot know the future&#39;s fs, we must make an assumption about the future. By our optimistic assumption that people will more and more positive about this epidemic, sentiment variable fs will increase by the time. We assume that fs will remain a fixed growth rate from 0 to 1 in 30 days. Then

we applied into our prediction model to describe how coronavirus will develop in the following 30 days. Figure 10 and 11 shows the results.

![image](/resource/dataset/picture/9.png)

Figure 9. The comparison of actual confirmed cases and our prediction model, blue lane is the prediction and the red line is the actual situation.

![image](/resource/dataset/picture/10.png)

Figure 10. The prediction of confirmed patients by the adjusted model

![image](/resource/dataset/picture/11.png)

Figure 11. The daily increased patients. Before 04/10, the curve is predicted by the actual fs. After 04/10, the curve is predicted by the assumed fs.

The results show that the total confirmed cases will reach 1,500,000 people amid May.

1. **Conclusion**

All of us are fighting against the coronavirus, which has influenced 1 million people in the U.S. from all walks of life. Therefore, we built an optimized prediction model of coronavirus based on NLP to give our opinion about how COVID-19 will develop in 30 days.

In this project, we used our knowledge about Natural Language Processing and regression model to fit our prediction model step by step. We used python packages, such as afinn and tweepy to collect and process the data; we used R to analyze the data and draw the figures; we used MATLAB to do the function fitting.

We collected data from two datasets: Novel COVID-19 data cases and the tweet id related to coronavirus data. After confirming our model fitting with the actual data from 03/01 to 04/10, we predicted the total number of confirmed cases with time series in the following 30 days. Our results show that the confirmed cases will be 1.5 million amid May under optimistic assumptions.

For future work, we should implement our prediction model in a longer time period, such as 3 months to test its accuracy. Moreover, we could take the recovered cases into consideration to predict this pandemic in a detailed and thorough perspective. Finally, we should reduce noise in our model, including the celebrity effect and resumption of work.

1. **Data source**

Time series of Covid-19 in US:[https://data.humdata.org/dataset/novel-coronavirus-2019-ncov-cases](https://data.humdata.org/dataset/novel-coronavirus-2019-ncov-cases)

Twitter corpus: [https://github.com/echen102/COVID-19-TweetIDs](https://github.com/echen102/COVID-19-TweetIDs)

1. **Git address**

Our project:[https://github.com/hwanggwu/CSCI\_6364\_ML\_FinalPorject](https://github.com/hwanggwu/CSCI_6364_ML_FinalPorject)
