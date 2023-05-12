#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -t -c"
echo -e "\n~~~~~ MY SALON ~~~~~"

MAIN_MENU() {
if [[ $1 ]]
then
  echo -e "\n$1"
else
  echo -e "\nWelcome to My Salon, how can I help you?\n"
fi
# get available services
AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
# display available services
echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
do
  echo "$SERVICE_ID) $NAME"
done
read SERVICE_ID_SELECTED
if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]] 
then
  # $SERVICE_ID_SELECTED is not a valid integer
  MAIN_MENU "I could not find that service. What would you like today?"
else
  # $SERVICE_ID_SELECTED is a valid integer
  # get selected service
  SELECTED_SERVICE=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  # if service doesn't exist
  if [[ -z $SELECTED_SERVICE ]]
  then
    # send to main menu
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    SERVICE_MENU
  fi
fi
}

SERVICE_MENU() {
# get customer info
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
# if customer doesn't exist
if [[ -z $CUSTOMER_NAME ]]
then
  # get new customer name
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  # insert new customer
  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
fi
CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed -E 's/^ *//g')
# get service name
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id='$SERVICE_ID_SELECTED'")
SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME | sed -E 's/^ *//g')
# get service time
echo -e "\nWhat time would you like your $SERVICE_NAME_FORMATTED, $CUSTOMER_NAME_FORMATTED?"
read SERVICE_TIME
# get customer_id
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
# insert new appointment
INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(time, service_id, customer_id) VALUES('$SERVICE_TIME', $SERVICE_ID_SELECTED, $CUSTOMER_ID)")
echo "I have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."
}

MAIN_MENU