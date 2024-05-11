#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~~~~~~~~~Welcome to Zen Nail Spa~~~~~~~~~~~~~\n"
echo -e "\nWelcome to My Salon, how can I help you?\n"

MAIN_MENU(){
  # show available services
  AVAILABLE_SERVICES=$($PSQL "SELECT * FROM services ORDER BY service_id")
  echo -e "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
  do 
    echo "$SERVICE_ID) $NAME"
  done
  # get user input
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    echo -e "\nThat is not a valid entry. Please enter a number.\n"
    MAIN_MENU 
  else
    SERVICE_SELECTION_VALIDITY=$($PSQL "SELECT service_id FROM services WHERE $SERVICE_ID_SELECTED=service_id")
    # if service selection is not valid
    if [[ -z $SERVICE_SELECTION_VALIDITY ]]
    then
      echo -e "\nThat is not a valid service.\n"
      MAIN_MENU 
    # if the service selection is valid then...
    else
    # get phone number and check if it exists
      echo -e "\nWhat's your phone number?\n"
      read CUSTOMER_PHONE
      CUSTOMER_NAME_EXIST=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
      # if name doesnt exists, then just add that customer info
      if [[ -z $CUSTOMER_NAME_EXIST  ]] 
      then
        echo -e "\nI see you're new to us. Welcome!\n"
        echo -e "\nWhat's your name?\n"
        read CUSTOMER_NAME
        # add that bitch in
        INSERT_NEW_CUSTOMER=$($PSQL "INSERT INTO customers(phone,name) VALUES('$CUSTOMER_PHONE','CUSTOMER_NAME')")
      fi
      # when customer already exists, then carry on with setting up appointments 
      # or carry on with appointments after the new customer is added
      echo -e "\nWhat time would you like to come in?\n"
      read SERVICE_TIME
      # insert appointments into the table
      # get customer id
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      INSERT_NEW_SERVICE=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES('$CUSTOMER_ID','$SERVICE_ID_SELECTED','$SERVICE_TIME')")
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
      echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -E 's/^ *| *$//g') at $SERVICE_TIME, $CUSTOMER_NAME."

    fi
  fi
}
MAIN_MENU

