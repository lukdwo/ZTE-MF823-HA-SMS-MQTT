#!/bin/bash

# The list of blocked keywords
declare -a BLOCKED=("uber eats" "block another keyword")

# ZTE-MF823 IP
URL=http://192.168.0.1
REFERER="$URL/index.html"
URL_SET="$URL/goform/goform_set_cmd_process"
URL_GET="$URL/goform/goform_get_cmd_process"

# MQTT variables
MQTT_IP=192.168.1.1
MQTT_USER=user
MQTT_PASS=password


command -v jq >/dev/null 2>&1 || { echo >&2 "'jq' is required but not installed. Aborting."; exit 1; }

#MQTT
# get OS version
DEVICE="MODEM_NET"
OS_VERSION="$(uname -r -o -s -m)"
SW_VERSION="WEB_ZTEUROPEMF823V1.0.1B02"

COMMAND="mosquitto_pub -h $MQTT_IP -p 1883 -u $MQTT_USER -P $MQTT_PASS -r"

AVAILABILITY_TOPIC="home/${DEVICE}/status"
STATE_TOPIC="home/${DEVICE}/state"
NUMBER_TOPIC="home/${DEVICE}/number"
IN_TOPIC="home/${DEVICE}/in"
OUT_TOPIC="home/${DEVICE}/out"
UPTIME_TOPIC="home/${DEVICE}/uptime"
L15_TOPIC="home/${DEVICE}/l15"

HASS_AUTO_CONF_NUMBER="homeassistant/sensor/sms_internet/number/config"
HASS_AUTO_CONF_STATE="homeassistant/sensor/sms_internet/state/config"
HASS_AUTO_CONF_IN="homeassistant/sensor/sms_internet/in/config"
HASS_AUTO_CONF_OUT="homeassistant/sensor/sms_internet/out/config"
HASS_AUTO_CONF_UPTIME="homeassistant/sensor/sms_internet/uptime/config"
HASS_AUTO_CONF_L15="homeassistant/sensor/sms_internet/l15/config"

# hass auto conf
$COMMAND -t "${HASS_AUTO_CONF_STATE}"  -m "{\"name\":\"MSG\",\"platform\":\"mqtt\",\"uniq_id\":\"${DEVICE}_MSG\",\"obj_id\":\"sms_internet_state\",\"icon\":\"mdi:cellphone-message\",\"avty_t\":\"${AVAILABILITY_TOPIC}\",\"pl_avail\":\"1\",\"pl_not_avail\":\"0\",\"stat_t\":\"${STATE_TOPIC}\",\"dev\":{\"identifiers\":[\"${DEVICE}_123\"],\"name\":\"${DEVICE}\",\"model\":\"ZTE-MF823\",\"sw_version\":\"${SW_VERSION}\",\"manufacturer\":\"${OS_VERSION}\"}}"
$COMMAND -t "${HASS_AUTO_CONF_NUMBER}"  -m "{\"name\":\"Number\",\"platform\":\"mqtt\",\"uniq_id\":\"${DEVICE}_NUMBER\",\"obj_id\":\"sms_internet_number\",\"icon\":\"mdi:format-list-numbered\",\"avty_t\":\"${AVAILABILITY_TOPIC}\",\"pl_avail\":\"1\",\"pl_not_avail\":\"0\",\"stat_t\":\"${NUMBER_TOPIC}\",\"dev\":{\"identifiers\":[\"${DEVICE}_123\"],\"name\":\"${DEVICE}\",\"model\":\"ZTE-MF823\",\"sw_version\":\"${SW_VERSION}\",\"manufacturer\":\"${OS_VERSION}\"}}"
$COMMAND -t "${HASS_AUTO_CONF_IN}"  -m "{\"name\":\"IN\",\"platform\":\"mqtt\",\"uniq_id\":\"${DEVICE}_IN\",\"obj_id\":\"sms_internet_in\",\"icon\":\"mdi:download-network\",\"avty_t\":\"${AVAILABILITY_TOPIC}\",\"pl_avail\":\"1\",\"pl_not_avail\":\"0\",\"stat_t\":\"${IN_TOPIC}\",\"dev\":{\"identifiers\":[\"${DEVICE}_123\"],\"name\":\"${DEVICE}\",\"model\":\"ZTE-MF823\",\"sw_version\":\"${SW_VERSION}\",\"manufacturer\":\"${OS_VERSION}\"}}"
$COMMAND -t "${HASS_AUTO_CONF_OUT}"  -m "{\"name\":\"OUT\",\"platform\":\"mqtt\",\"uniq_id\":\"${DEVICE}_OUT\",\"obj_id\":\"sms_internet_out\",\"icon\":\"mdi:upload-network\",\"avty_t\":\"${AVAILABILITY_TOPIC}\",\"pl_avail\":\"1\",\"pl_not_avail\":\"0\",\"stat_t\":\"${OUT_TOPIC}\",\"dev\":{\"identifiers\":[\"${DEVICE}_123\"],\"name\":\"${DEVICE}\",\"model\":\"ZTE-MF823\",\"sw_version\":\"${SW_VERSION}\",\"manufacturer\":\"${OS_VERSION}\"}}"
$COMMAND -t "${HASS_AUTO_CONF_UPTIME}"  -m "{\"name\":\"Uptime\",\"platform\":\"mqtt\",\"uniq_id\":\"${DEVICE}_UPTIME\",\"obj_id\":\"sms_internet_uptime\",\"icon\":\"mdi:time\",\"avty_t\":\"${AVAILABILITY_TOPIC}\",\"pl_avail\":\"1\",\"pl_not_avail\":\"0\",\"stat_t\":\"${UPTIME_TOPIC}\",\"dev\":{\"identifiers\":[\"${DEVICE}_123\"],\"name\":\"${DEVICE}\",\"model\":\"ZTE-MF823\",\"sw_version\":\"${SW_VERSION}\",\"manufacturer\":\"${OS_VERSION}\"}}"
$COMMAND -t "${HASS_AUTO_CONF_L15}"  -m "{\"name\":\"L15\",\"platform\":\"mqtt\",\"uniq_id\":\"${DEVICE}_L15\",\"obj_id\":\"sms_internet_l15\",\"icon\":\"mdi:chart-areaspline\",\"avty_t\":\"${AVAILABILITY_TOPIC}\",\"pl_avail\":\"1\",\"pl_not_avail\":\"0\",\"stat_t\":\"${L15_TOPIC}\",\"dev\":{\"identifiers\":[\"${DEVICE}_123\"],\"name\":\"${DEVICE}\",\"model\":\"ZTE-MF823\",\"sw_version\":\"${SW_VERSION}\",\"manufacturer\":\"${OS_VERSION}\"}}"



{ echo "root"; sleep 2; echo "zte9x15"; sleep 1; echo "ifconfig rmnet0"; sleep 1; } | telnet 192.168.0.1 > ~/scripts/zte.in
IN="$(cat ~/scripts/zte.in | tail -n 3 | head -n 1 | cut -d "(" -f 2 | cut -d ")" -f 1 | cut -d " " -f 1)"
echo $IN
$COMMAND -t "${IN_TOPIC}" -m "$IN"
OUT="$(cat ~/scripts/zte.in | tail -n 3 | head -n 1 | cut -d "(" -f 3 | cut -d ")" -f 1 | cut -d " " -f 1)"
echo $OUT
$COMMAND -t "${OUT_TOPIC}" -m "$OUT"

{ echo "root"; sleep 2; echo "zte9x15"; sleep 1; echo "uptime"; sleep 1; } | telnet 192.168.0.1 > ~/scripts/zte.uptime
UPTIME="$(cat ~/scripts/zte.uptime | tail -n 2 | head -n 1 | cut -d "," -f 1)"
$COMMAND -t "${UPTIME_TOPIC}" -m "$UPTIME"
L15="$(cat ~/scripts/zte.uptime | tail -n 2 | head -n 1 | cut -d "," -f 5)"
$COMMAND -t "${L15_TOPIC}" -m "$L15"

IS_LOGGED=$(curl -s --header "Referer: $REFERER" $URL_GET\?multi_data\=1\&isTest\=false\&sms_received_flag_flag\=0\&sts_received_flag_flag\=0\&cmd\=loginfo | jq --raw-output .loginfo)

# Login
if [ "$IS_LOGGED" == "ok" ]; then
    echo "Zalogowany do ZTE:"
    $COMMAND -t "${AVAILABILITY_TOPIC}" -m "1"
else
    LOGIN=$(curl -s --header "Referer: $REFERER" -d 'isTest=false&goformId=LOGIN&password=YWRtaW4=' $URL_SET | jq --raw-output .result)
    echo "Logowanie do ZTE"

    # Disable wifi
    curl -s --header "Referer: $REFERER" -d 'goformId=SET_WIFI_INFO&isTest=false&m_ssid_enable=0&wifiEnabled=0' $URL_SET > /dev/null

    if [ "$LOGIN" == "0" ]; then
      echo "Zalogowany:"
          $COMMAND -t "${AVAILABILITY_TOPIC}" -m "1"
    else
      echo "Blad logowania do ZTE"
          $COMMAND -t "${AVAILABILITY_TOPIC}" -m "0"
      exit
    fi
fi

SMS=$(curl -s --header "Referer: $REFERER" $URL_GET\?multi_data\=1\&isTest\=false\&sms_received_flag_flag\=0\&sts_received_flag_flag\=0\&cmd\=sms_unread_num)
UNREAD_SMS=$(echo "$SMS" | jq --raw-output .sms_unread_num)

# Get unread messages
if [ "$UNREAD_SMS" == "0" ]; then
  echo "Brak wiadomosci"
  $COMMAND -t "${NUMBER_TOPIC}" -m "$UNREAD_SMS"
  exit
else
  echo "Masz $UNREAD_SMS sms"

  MESSAGES=$(curl -s --header "Referer: $REFERER" $URL_GET\?isTest\=false\&cmd\=sms_data_total\&page\=0\&data_per_page\=500\&mem_store\=1\&tags\=10\&order_by\=order+by+id+desc)

  for MESSAGE in $(echo $MESSAGES | tr -d ' ' | jq -c '.messages | values []'); do
    TAG=$(echo $MESSAGE | jq --raw-output .tag)

    if [ "$TAG" == "1" ]; then
      ID=$(echo $MESSAGE | jq --raw-output .id)
      CONTENT=$(echo $MESSAGE | jq --raw-output .content | tr '\0' '\n' | xxd -r -p | tr -d '\0')

      echo "Wiadomosc: $CONTENT"
      $COMMAND -t "${STATE_TOPIC}" -m "$CONTENT"
      # Set message as read
      curl -s --header "Referer: $REFERER" -d "isTest=false&goformId=SET_MSG_READ&msg_id=$ID;&tag=0" $URL_SET > /dev/null

      # End right there if a blocked keyword is found
      for STR in "${BLOCKED[@]}"; do
        if [ "$(echo $CONTENT | grep -i "$STR")" ]; then
          echo "$STR is blocked"
          exit
        fi
      done

  fi
  done
  $COMMAND -t "${NUMBER_TOPIC}" -m "$UNREAD_SMS"
fi
