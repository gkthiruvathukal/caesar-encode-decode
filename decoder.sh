#!/bin/bash

# This tries all rotations of Caesar cipher 
# These are all parameters. I am going to make command line options to handle them.
# for now, however, you can just change them as needed.

# Parameters (options)

ALPHABET="ABCDEFGHIJKLMNOPQRSTUVWXYZ"    # -a
WORDLIST=(`aspell -l en dump master`)   # -w 
SENTENCES=25                             # -s
MIN_SENTENCE_LENGTH=3                    # -l
MAX_ADDL_SENTENCE_WORDS=25	         # -h

while getopts ":a:w:s:l:" opt; do
  case $opt in
    a) 
      ALPHABET=$OPTARG
      ;;
    w)
      if [ -f "$OPTARG" ]; then
         WORDLIST=`cat $OPTARG`
      else
	 echo "$OPTARG does not exist; defaulting to /usr/share/dict/words"
      fi
      ;;
    s)
      SENTENCES=$OPTARG
      ;;
    l)
      MIN_SENTENCE_LENGTH=$OPTARG
      echo "Min sentence length set to $MIN_SENTENCE_LENGTH."
      ;;

    h)
      MAX_ADDL_SENTENCE_WORDS=$OPTARG
      ;;

    \?)
      echo "Invalid option: -$OPTARG"
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument."
      exit 1
      ;;
  esac
done

NUM_WORDS=${#WORDLIST[@]}

while read line; do
  line_key=${#ALPHABET}
  line_key_errors=$(echo "$line" | wc -w)
  line_plaintext=""
  for ((i=0; i < ${#ALPHABET}; i++)); do
    SHIFT_VALUE=$i
    CAESAR=${ALPHABET:$SHIFT_VALUE}${ALPHABET:0:$SHIFT_VALUE}
    #echo "$line" | tr '[:lower:]' '[:upper:]' | tr -d '[:punct:]' | tr $CAESAR $ALPHABET
    this_shift_errors=`echo "$line" | tr '[:lower:]' '[:upper:]' | tr -d '[:punct:]' | tr $CAESAR $ALPHABET | aspell list | wc -l`
    #echo "shift $SHIFT_VALUE errors: $this_shift_errors"
    if [ $this_shift_errors -lt $line_key_errors ]; then 
      line_key=$SHIFT_VALUE
      line_key_errors=$this_shift_errors
      line_plaintext=`echo "$line" | tr '[:lower:]' '[:upper:]' | tr -d '[:punct:]' | tr $CAESAR $ALPHABET`
    fi
  done
  echo "{ key: $line_key, errors: $line_key_errors, plaintext: \"$line_plaintext\"" }
done
