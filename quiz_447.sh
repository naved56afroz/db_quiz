# !/bin/bash

        NORMAL=$(echo "\033[m")
    MENU=$(echo "\033[36m") #Blue
    NUMBER=$(echo "\033[33m") #yellow
    FGRED=$(echo "\033[41m")
    RED_TEXT=$(echo "\033[31m")
        BNB=$(echo "\e[1m") # bold and bright
        FONT="\033#6" # font type for wider text
         BLINK=$(echo "\e[42m") #bgreen
         GREEN="32"
        BOLDGREEN=$(echo "\e[1;${GREEN}m")
clear                                                                           # clear screen
score=0                                                                                 # initialize score to 0
qno=1
total=100
SCRIPTS_DIR=/refresh/home/script

set_env ()
{
# Local .env
cd /home/oracle
    # Load Environment Variables
    /refresh/home/db.env
if [ "$ORACLE_SID" ==  "orcl19800" ]
then
   echo $sid
else
    echo "No .env file found" 1>&2
    return 1
fi
}

insert_record ()
{
sqlplus -S "/ as sysdba" <<EOF
set timing on
set trimspool on
@$SCRIPTS_DIR/$1.sql $name $score $qno-$score $score/$total*100
EOF
} > /dev/null

performance_history ()
{
sqlplus -S "/ as sysdba" <<EOF
SET VERIFY OFF PAGES 100
alter session set nls_date_format='dd-mm-yyyy hh24:mi';
set line 400
col name for a40
@$SCRIPTS_DIR/hist.sql $name
EOF
} > $SCRIPTS_DIR/hist_log.out

set_env
echo -e "${MENU} Enter your Name : ${NORMAL}"
read name
insert_record insert_name $name
 mv $SCRIPTS_DIR/quiz_dataset.txt $SCRIPTS_DIR/quiz_dataset_main.txt
shuf $SCRIPTS_DIR/quiz_dataset_main.txt > $SCRIPTS_DIR/quiz_dataset.txt
cat /dev/null > $SCRIPTS_DIR/wrong_answers.txt
#$SCRIPTS_DIR/timer.sh
while IFS='#' read -r question choices answer   # uses "#" as a separator to separate in the format - question,options,answer.
do                                                                                              # loop to keep asking qns
    echo                                                                                # prints a blank line
    echo -e "${MENU} ----------------------------------------------------- ${NORMAL}"
    echo

    echo -e "$FONT ${BNB}     WELCOME TO THE QUIZ ! ${NORMAL}"
    echo
    echo
    echo -e "${MENU} --------------------------------------------------- ${NORMAL}"
    echo
    echo "There are a total of 100 questions in this quiz "
    echo
    echo "------------press 0 to get summary and exit anytime-------------------------------         "
    echo
    echo "Q"$qno"." $question                                   # prints qn on the screen
        attempt=`expr $qno - 1`
        qno=`expr $qno + 1`
        echo
    echo -e "${NUMBER} $choices ${NORMAL}"                                                 # prints choices for the qn
        echo
        echo -e "Your Answer:                                                                                                    ${BOLDGREEN}Score : $score/$attempt${NORMAL}"
        read student_answer </dev/tty                           # input the user's ans from terminal
        if [ "$student_answer" = "$answer" ]
         then
                echo -e "${BOLDGREEN} Your Answer is correct ${NORMAL}"
                score=`expr $score + 1`                                 # increment score for every correct ans
                insert_record update_score $name
                elif [ "$student_answer" = "0" ]
                  then
                                echo "Your Final Score is: $score out of $qno"
                        echo "Your Score Percentage is: $score %"
                                echo "*****Performance History********"
                                echo ""
                                performance_history $name
                                cat $SCRIPTS_DIR/hist_log.out
                                exit 0
         else
            echo -e "${RED_TEXT}oops wrong answer #@$%@#@!!!!! ${NORMAL}"
            echo -e "${MENU} Correct Answer is option $answer ${NORMAL}"
                       insert_record update_score $name
                        echo "$question#$choices#$answer" >> $SCRIPTS_DIR/wrong_answers.txt
        fi                                                                              # end of if
         read  opt </dev/tty
        clear
done <$SCRIPTS_DIR/quiz_dataset.txt                                                  # text file having the dataset for the quiz

echo
echo "Your Score is: $score"
echo "Your Score Percentage is: $score %"
echo
 echo "Your Final Score is: $score out of $qno"
                        echo "Your Score Percentage is: $score %"
                                echo "*****Performance History********"
                                echo ""
                                performance_history $name
                                cat $SCRIPTS_DIR/hist_log.out
