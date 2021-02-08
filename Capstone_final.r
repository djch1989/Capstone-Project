library(tm)
library(ggplot2)
library(RWeka)
library(R.utils)
library(dplyr)
library(parallel)
library(wordcloud)
library(stringi)
library(NLP)

twitter<-readLines("en_US.twitter.txt",warn=FALSE,encoding="UTF-8")
blogs<-readLines("en_US.blogs.txt",warn=FALSE,encoding="UTF-8")
news<-readLines("en_US.news.txt",warn=FALSE,encoding="UTF-8")


length(twitter)

length(blogs)

length(news)

set.seed(1234)

blogs_c<-iconv(blogs,"latin1","ASCII",sub="")
news_c<-iconv(news,"latin1","ASCII",sub="")
twitter_c<-iconv(twitter,"latin1","ASCII",sub="")


set.seed(10000)

#Using binomial distribution to sample data from the text files

sampledata<-c(twitter_c[rbinom(length(twitter_c)*.01, length(twitter_c), .5)],
              news_c[rbinom(length(news_c)*.01, length(news_c), .5)],
              blogs_c[rbinom(length(blogs_c)*.01, length(blogs_c), .5)])


#Write the sampled data to a text file
writeLines(sampledata, "./sampledata/sampledata.txt")



#cleaning and tokenizing sampled text

corpus <- VCorpus(DirSource("./sampledata", encoding = "UTF-8"))
toSpace <- content_transformer(function(x, pattern) gsub(pattern, " ", x))
corpus <- tm_map(corpus, toSpace, "(f|ht)tp(s?)://(.*)[.][a-z]+")
corpus <- tm_map(corpus, toSpace, "@[^\\s]+")
corpus <- tm_map(corpus, tolower)
corpus <- tm_map(corpus, removeWords, stopwords("en"))
corpus <- tm_map(corpus, removePunctuation)
corpus <- tm_map(corpus, removeNumbers)
corpus <- tm_map(corpus, stripWhitespace)
corpus <- tm_map(corpus, PlainTextDocument)


removeNumPunct <- function(x) gsub("[^[:alpha:][:space:]]*", "", x)
corpus <- tm_map(corpus, content_transformer(removeNumPunct))

#Calculate bi-Grams, extract term-count tables from bi-Grams and sort 

bigram_func<-function(x) NGramTokenizer(x,Weka_control(min=2,max=2))
bigramtab<-TermDocumentMatrix(corpus,control=list(tokenizer=bigram_func))
matrix_bigramtab <- as.matrix(bigramtab)
dataframe_bigram <- as.data.frame(matrix_bigramtab)
colnames(dataframe_bigram) <- "Count"
dataframe_bigram <- dataframe_bigram[order(-dataframe_bigram$Count), , drop = FALSE]

#Save bigram data frame into r-compressed file in .RData format

bigram <- data.frame(rows=rownames(dataframe_bigram),count=dataframe_bigram$Count)
bigram$rows <- as.character(bigram$rows)
bigram_split <- strsplit(as.character(bigram$rows),split=" ")
bigram <- transform(bigram,first = sapply(bigram_split,"[[",1),second = sapply(bigram_split,"[[",2))
bigram <- data.frame(unigram = bigram$first,bigram = bigram$second,freq = bigram$count,stringsAsFactors=FALSE)
write.csv(bigram[bigram$freq > 1,],"./ShinyApp/bigram.csv",row.names=F)
bigram <- read.csv("./ShinyApp/bigram.csv",stringsAsFactors = F)
saveRDS(bigram,"./ShinyApp/bigram.RData")

#Calculate tri-Grams, extract term-count tables from tri-Grams and sort 

trigram_func<-function(x) NGramTokenizer(x,Weka_control(min=3,max=3))
trigramtab<-TermDocumentMatrix(corpus,control=list(tokenizer=trigram_func))
matrix_trigramtab <- as.matrix(trigramtab)
dataframe_trigram <- as.data.frame(matrix_trigramtab)
colnames(dataframe_trigram) <- "Count"
dataframe_trigram <- dataframe_trigram[order(-dataframe_trigram$Count), , drop = FALSE]

#Save trigram data frame into r-compressed file in .RData format

trigram <- data.frame(rows=rownames(dataframe_trigram),count=dataframe_trigram$Count)
trigram$rows <- as.character(trigram$rows)
trigram_split <- strsplit(as.character(trigram$rows),split=" ")
trigram <- transform(trigram,first = sapply(trigram_split,"[[",1),second = sapply(trigram_split,"[[",2),third = sapply(trigram_split,"[[",3))
trigram <- data.frame(unigram = trigram$first,bigram = trigram$second, trigram = trigram$third, freq = trigram$count,stringsAsFactors=FALSE)
write.csv(trigram[trigram$freq > 1,],"./ShinyApp/trigram.csv",row.names=F)
trigram <- read.csv("./ShinyApp/trigram.csv",stringsAsFactors = F)
saveRDS(trigram,"./ShinyApp/trigram.RData")

#Calculate quad-Grams, extract term-count tables from quad-Grams and sort

quadgram_func<-function(x) NGramTokenizer(x,Weka_control(min=4,max=4))
quadgramtab<-TermDocumentMatrix(corpus,control=list(tokenize=quadgram_func))
matrix_quadgramtab <- as.matrix(quadgramtab)
dataframe_quadgram <- as.data.frame(matrix_quadgramtab)
colnames(dataframe_quadgram) <- "Count"
dataframe_quadgram <- dataframe_quadgram[order(-dataframe_quadgram$Count), , drop = FALSE]

#Save quadgram data frame into r-compressed file in .RData format

quadgram <- data.frame(rows=rownames(dataframe_quadgram),count=dataframe_quadgram$Count)
quadgram$rows <- as.character(quadgram$rows)
quadgram_split <- strsplit(as.character(quadgram$rows),split=" ")
quadgram <- transform(quadgram,first = sapply(quadgram_split,"[[",1),second = sapply(quadgram_split,"[[",2),third = sapply(quadgram_split,"[[",3), fourth = sapply(quadgram_split,"[[",4))
quadgram <- data.frame(unigram = quadgram$first,bigram = quadgram$second, trigram = quadgram$third, quadgram = quadgram$fourth, freq = quadgram$count,stringsAsFactors=FALSE)
write.csv(quadgram[quadgram$freq > 1,],"./ShinyApp/quadgram.csv",row.names=F)
quadgram <- read.csv("./ShinyApp/quadgram.csv",stringsAsFactors = F)
saveRDS(quadgram,"./ShinyApp/quadgram.RData")
