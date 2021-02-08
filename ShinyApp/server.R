#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

suppressWarnings(library(tm))
suppressWarnings(library(stringr))
suppressWarnings(library(shiny))

# Load Quadgram,Trigram & Bigram Data frame files

quadgram <- readRDS("quadgram.RData");
trigram <- readRDS("trigram.RData");
bigram <- readRDS("bigram.RData");
message_text <<- ""

#Storing 12 most common unigrams in a character vector
f <- c("just", "will", "like", "get", "can","now","day","time","new","know","good","today")

# Cleaning of user input before predicting the next word

Predict <- function(x) {
    cleanedtext <- removeNumbers(removePunctuation(tolower(x)))
    inputtext <- strsplit(cleanedtext, " ")[[1]]
    
    # Katz Backoff Algorithm is used to predict the next term of the user input sentence
    # 1. For prediction of the next word, Quadgram is first used followed by backing off to Trigram and Bigram if Quadgram and Trigram is not found respectively
    # 2. If no Bigram is found, the algorithm here back off to a random word among the Top 10 unigrams found in Milestone report and return it
    # 3. We rely on a discounted probability P if we have seen this n-gram before, that is, if we have non-zero counts. Otherwise, we recursively back off to the Katz probability for the shorter-history (N-1)-gram
    # 4. Reference - https://web.stanford.edu/~jurafsky/slp3/3.pdf
    
    
    if (length(inputtext)>= 3) {
        inputtext <- tail(inputtext,3)
        if (identical(character(0),head(quadgram[quadgram$unigram == inputtext[1] & quadgram$bigram == inputtext[2] & quadgram$trigram == inputtext[3], 4],1))){
            Predict(paste(inputtext[2],inputtext[3],sep=" "))
        }
        else {message_text <<- "N Gram used to predict: quadgram."; head(quadgram[quadgram$unigram == inputtext[1] & quadgram$bigram == inputtext[2] & quadgram$trigram == inputtext[3], 4],1)}
    }
    else if (length(inputtext) == 2){
        inputtext <- tail(inputtext,2)
        if (identical(character(0),head(trigram[trigram$unigram == inputtext[1] & trigram$bigram == inputtext[2], 3],1))) {
            Predict(inputtext[2])
        }
        else {message_text <<- "N Gram used to predict: trigram."; head(trigram[trigram$unigram == inputtext[1] & trigram$bigram == inputtext[2], 3],1)}
    }
    else if (length(inputtext) == 1){
        inputtext <- tail(inputtext,1)
        if (identical(character(0),head(bigram[bigram$unigram == inputtext[1], 2],1))) {message_text<<-"No match found. One of the most common unigrams is returned."; f[as.integer(runif(1,1,12))]}
        else {message_text <<- "N Gram used to predict: bigram."; head(bigram[bigram$unigram == inputtext[1],2],1)}
    }
}


shinyServer(function(input, output) {
    output$prediction <- renderPrint({
        result <- Predict(input$inputString)
        output$text2 <- renderText({message_text})
        result
    });
    
    output$text1 <- renderText({
        input$inputString});
}
)