#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

USER_DATA=$($PSQL "SELECT user_id, games_played, best_game FROM users WHERE username='$USERNAME'")

if [[ -z $USER_DATA ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
else
  echo "$USER_DATA" | while IFS="|" read USER_ID GAMES_PLAYED BEST_GAME
  do
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi

SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
echo "Guess the secret number between 1 and 1000:"

NUMBER_OF_GUESSES=0

while true
do
  read GUESS

  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  else
    NUMBER_OF_GUESSES=$(( NUMBER_OF_GUESSES + 1 ))

    if [[ $GUESS -eq $SECRET_NUMBER ]]
    then
      echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
      break
    elif [[ $GUESS -lt $SECRET_NUMBER ]]
    then
      echo "It's higher than that, guess again:"
    else
      echo "It's lower than that, guess again:"
    fi
  fi
done

if [[ -z $USER_DATA ]]
then
  UPDATE_USER=$($PSQL "UPDATE users SET games_played = 1, best_game = $NUMBER_OF_GUESSES WHERE username='$USERNAME'")
else
  echo "$USER_DATA" | while IFS="|" read USER_ID GAMES_PLAYED BEST_GAME
  do
    GAMES_PLAYED=$(( GAMES_PLAYED + 1 ))
    if [[ $NUMBER_OF_GUESSES -lt $BEST_GAME || $BEST_GAME -eq 0 ]]
    then
      UPDATE_USER=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED, best_game=$NUMBER_OF_GUESSES WHERE username='$USERNAME'")
    else
      UPDATE_USER=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED WHERE username='$USERNAME'")
    fi
  done
fi
