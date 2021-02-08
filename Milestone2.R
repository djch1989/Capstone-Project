

if(!file.exists("./Capstone Project")){
  dir.create("./Capstone Project")
}
Url <- "https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip"
 
if(!file.exists("./Capstone Project/Coursera-SwiftKey.zip")){
  download.file(Url,destfile="./Capstone Project/Coursera-SwiftKey.zip",mode = "wb")
}

if(!file.exists("./Capstone Project/final")){
  unzip(zipfile="./Capstone Project/Coursera-SwiftKey.zip",exdir="./Capstone Project")
}




setwd("./Capstone Project/final/en_US")

if(!file.exists("full-list-of-bad-words_text-file_2018_07_30.txt")){
  download.file("https://www.freewebheaders.com/download/files/full-list-of-bad-words_text-file_2018_07_30.zip",destfile="full-list-of-bad-words_text-file_2018_07_30.zip",mode = "wb")
}

if(!file.exists("full-list-of-bad-words_text-file_2018_07_30.txt")){
  unzip(zipfile="full-list-of-bad-words_text-file_2018_07_30.zip")
}


twitter<-readLines("en_US.twitter.txt",warn=FALSE,encoding="UTF-8")
blogs<-readLines("en_US.blogs.txt",warn=FALSE,encoding="UTF-8")
news<-readLines("en_US.news.txt",warn=FALSE,encoding="UTF-8")

library(stringi)
length(twitter)

length(blogs)

length(news)

twitterwords <-stri_stats_latex(twitter)[4]
blogswords <-stri_stats_latex(blogs)[4]
newswords <-stri_stats_latex(news)[4]
nchar_twitter<-sum(nchar(twitter))
nchar_blogs<-sum(nchar(blogs))
nchar_news<-sum(nchar(news))

data.frame("File Name" = c("twitter", "blogs", "news"),
           "num.lines" = c(length(twitter),length(blogs), length(news)),
           "num.words" = c(sum(blogswords), sum(newswords), sum(twitterwords)),
           "Num of character"=c(nchar_blogs,nchar_news,nchar_twitter))

set.seed(1234)
blogs_c<-iconv(blogs,"latin1","ASCII",sub="")
news_c<-iconv(news,"latin1","ASCII",sub="")
twitter_c<-iconv(twitter,"latin1","ASCII",sub="")

library(tm)

library(NLP)

set.seed(10000)

sampledata<-c(twitter_c[rbinom(length(twitter_c)*.01, length(twitter_c), .5)],
              news_c[rbinom(length(news_c)*.01, length(news_c), .5)],
              blogs_c[rbinom(length(blogs_c)*.01, length(blogs_c), .5)])

corpus <- VCorpus(VectorSource(sampledata))
toSpace <- content_transformer(function(x, pattern) gsub(pattern, " ", x))
corpus <- tm_map(corpus, toSpace, "(f|ht)tp(s?)://(.*)[.][a-z]+")
corpus <- tm_map(corpus, toSpace, "@[^\\s]+")
corpus <- tm_map(corpus, tolower)
corpus <- tm_map(corpus, removeWords, stopwords("en"))
corpus <- tm_map(corpus, removePunctuation)
corpus <- tm_map(corpus, removeNumbers)
corpus <- tm_map(corpus, stripWhitespace)
corpus <- tm_map(corpus, PlainTextDocument)


profanewords <- read.table("./full-list-of-bad-words_text-file_2018_07_30.txt",skip=14)
corpus <- tm_map(corpus, removeWords, profanewords)

removeNumPunct <- function(x) gsub("[^[:alpha:][:space:]]*", "", x)
corpus <- tm_map(corpus, content_transformer(removeNumPunct))



corpusresult<-data.frame(text=unlist(sapply(corpus,'[',"content")),stringsAsFactors = FALSE)
head(corpusresult)

library(wordcloud)
wordcloud(corpus, max.words=50, random.order = 0, random.color = 1,colors=brewer.pal(8, "Accent"))


library(RWeka)
library(ggplot2)

unigram<-function(x) NGramTokenizer(x,Weka_control(min=1,max=1))
unigramtab<-TermDocumentMatrix(corpus,control=list(tokenize=unigram))

unigramcorpus<-findFreqTerms(unigramtab,lowfreq=1000)
unigramcorpusnum<-rowSums(as.matrix(unigramtab[unigramcorpus,]))
unigramcorpustab<-data.frame(Word=names(unigramcorpusnum),frequency=unigramcorpusnum)
unigramcorpussort<-unigramcorpustab[order(-unigramcorpustab$frequency),]

wordcloud(unigramcorpussort$Word, unigramcorpussort$frequency,  max.words = 100, random.order = 0, scale = c(5,1), colors=brewer.pal(8, "Accent"))

ggplot(unigramcorpussort[1:15,],aes(x=reorder(Word,-frequency),y=frequency))+
  geom_bar(stat="identity",fill = I("grey50"))+
  labs(title="Unigrams",x="Most Words",y="Frequency")+
  theme(axis.text.x=element_text(angle=60))

bigram<-function(x) NGramTokenizer(x,Weka_control(min=2,max=2))
bigramtab<-TermDocumentMatrix(corpus,control=list(tokenize=bigram))
bigramcorpus<-findFreqTerms(bigramtab,lowfreq=80)
bigramcorpusnum<-rowSums(as.matrix(bigramtab[bigramcorpus,]))
bigramcorpustab<-data.frame(Word=names(bigramcorpusnum),frequency=bigramcorpusnum)
bigramcorpussort<-bigramcorpustab[order(-bigramcorpustab$frequency),]

wordcloud(bigramcorpussort$Word, bigramcorpussort$frequency,  max.words = 100, random.order = 0, scale = c(2,1), colors=brewer.pal(8, "Accent"))


ggplot(bigramcorpussort[1:12,],aes(x=reorder(Word,-frequency),y=frequency))+
  geom_bar(stat="identity",fill = I("grey50"))+
  labs(title="Bigrams",x="Most Words",y="Frequency")+
  theme(axis.text.x=element_text(angle=60))

trigram<-function(x) NGramTokenizer(x,Weka_control(min=3,max=3))
trigramtab<-TermDocumentMatrix(corpus,control=list(tokenize=trigram))
trigramcorpus<-findFreqTerms(trigramtab,lowfreq=10)
trigramcorpusnum<-rowSums(as.matrix(trigramtab[trigramcorpus,]))
trigramcorpustab<-data.frame(Word=names(trigramcorpusnum),frequency=trigramcorpusnum)
trigramcorpussort<-trigramcorpustab[order(-trigramcorpustab$frequency),]

wordcloud(trigramcorpussort$Word, trigramcorpussort$frequency,  max.words = 100, random.order = 0, scale = c(1.5,0.5), colors=brewer.pal(8, "Accent"))


ggplot(trigramcorpussort[1:10,],aes(x=reorder(Word,-frequency),y=frequency))+
  geom_bar(stat="identity",fill = I("grey50"))+
  labs(title="Trigrams",x="Most Words",y="Frequency")+
  theme(axis.text.x=element_text(angle=60))