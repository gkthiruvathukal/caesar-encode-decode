#!/bin/bash

# This tries all rotations of Caesar cipher


# These are all parameters. I am going to make command line options to handle them.
# for now, however, you can just change them as needed.

# Parameters (options)

ALPHABET="ABCDEFGHIJKLMNOPQRSTUVWXYZ"    # -a
SENTENCES=25                             # -s
MIN_SENTENCE_LENGTH=3                    # -l
MAX_ADDL_SENTENCE_WORDS=25	         # -h
WORDLIST=(`aspell -l en dump master`)   # -w ... note: You can use your own wordlist, but the words must spell correctly

while getopts ":a:w:s:l:p" opt; do
  case $opt in
    a) 
      ALPHABET=$OPTARG
      ;;
    w)
      if [ -f "$OPTARG" ]; then
        WORDLIST=(`cat $OPTARG`)
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

for ((i=0; i < $SENTENCES; i++))
do
    # get random shift (the key)
    while true; do
       SHIFT_VALUE=$(($RANDOM % ${#ALPHABET}))
       [[ $SHIFT_VALUE -eq 0 ]] || break
    done
	

    # Don't allow shift of 0, which is the same ALPHABET
    if [ $SHIFT_VALUE -lt 0 ]; then
	    s=1
    fi

    # generate some words
    SENTENCE_LENGTH=$(($MIN_SENTENCE_LENGTH + $RANDOM % $MAX_ADDL_SENTENCE_WORDS))
    SENTENCE=""
    C_SENTENCE=""
    CAESAR=${ALPHABET:$SHIFT_VALUE}${ALPHABET:0:$SHIFT_VALUE}
    for ((j=0; j < $SENTENCE_LENGTH; j++))
    do
       while true; do
          RANDOM_WORD_POS=$(($RANDOM % $NUM_WORDS))
          WORD=`echo ${WORDLIST[$RANDOM_WORD_POS]} | tr '[:lower:]' '[:upper:]'`
          C_WORD=$(echo $WORD | tr $ALPHABET $CAESAR)

          # For a word to be valid, every character must translate to a new character
          # There are many non-ASCII characters in the English dictionary!
          VALID_WORD=1
          for ((k=0; k < ${#WORD}; k++))
          do
            if [ "${WORD:k:1}" == "${C_WORD:k:1}" ]; then
               VALID_WORD=0
            fi
          done

          # In addition, aspell seems to have a minor bug where sometimes words do not
          # check correctly. So any word that does not encode to a spellable word is
          # not emitted.
          if [ $VALID_WORD -eq 1 ]; then
            WORD_SPELLING_ERRORS=$(echo "$WORD" | aspell --ignore-case list | wc -l)
            if [ $WORD_SPELLING_ERRORS -eq 0 ]; then
               break
            fi
          fi
       done
       SENTENCE="$SENTENCE ${WORD}"
       C_SENTENCE="$C_SENTENCE ${C_WORD}"
    done
    SENTENCE=${SENTENCE:1}
    C_SENTENCE=${C_SENTENCE:1}
    echo $C_SENTENCE
done

