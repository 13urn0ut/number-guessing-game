#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -q -c"

NUMBER=$((1 + $RANDOM % 1000))

echo -e "\nEnter your username:"

read USERNAME

GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username = '$USERNAME';")

if ! [[ $GAMES_PLAYED ]]
 then
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
  echo $($PSQL "INSERT INTO users(username, games_played) VALUES('$USERNAME', 0)")
 else
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username = '$USERNAME';")
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi  

echo -e "\nGuess the secret number between 1 and 1000:"

NUM_OF_GUESSES=0

GUESS_THE_NUMBER () {
  read GUESS_NUMBER
  NUM_OF_GUESSES=$((++NUM_OF_GUESSES))
  if ! [[ $GUESS_NUMBER =~ ^[0-9]+$ ]]
   then
    echo -e "\nThat is not an integer, guess again:"
    GUESS_THE_NUMBER
   elif [[ $GUESS_NUMBER > $NUMBER ]]
    then
     echo -e "\nIt's lower than that, guess again:"
     GUESS_THE_NUMBER
   elif [[ $GUESS_NUMBER < $NUMBER ]]
    then
     echo -e "\nIt's higher than that, guess again:"
     GUESS_THE_NUMBER
   else  
    if [[ $NUM_OF_GUESSES < $BEST_GAME || $BEST_GAME == "" ]]
     then
      BEST_GAME=$NUM_OF_GUESSES
    fi  
    echo $($PSQL "UPDATE users SET games_played = $GAMES_PLAYED + 1, best_game = $BEST_GAME WHERE username = '$USERNAME'")
    echo -e "\nYou guessed it in $NUM_OF_GUESSES tries. The secret number was $NUMBER. Nice job!"
  fi  
}

GUESS_THE_NUMBER
