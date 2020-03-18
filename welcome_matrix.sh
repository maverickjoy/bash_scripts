init()
{
  symbols="hexadecimal"
  frequency=1
  intro_scroll_speed=0
  outro_scroll_speed=0
  ending="fade"

  # Terminal window parameters
  screenlines=$(expr `tput lines` - 1 + $intro_scroll_speed)
  screencols=$(expr `tput cols` / 2 - 1)

  chars=(ｱ ｲ ｳ ｴ ｵ ｶ ｷ ｸ ｹ ｺ ｻ ｼ ｽ ｾ ｿ ﾀ ﾁ ﾂ ﾃ ﾄ ﾅ ﾆ ﾇ) ;
  count=${#chars[@]}

  # Compute the divisor for the random modulus
  divisor=`expr 101 - $frequency`

  clear

  # Hide and position the cursor
  tput civis
  tput cup 0 0

  for(( x=0; x<15; x++ ))
  do
    for i in $(eval echo {1..$screenlines})
    do
      for i in $(eval echo {1..$screencols})
      do
        rand=$(($RANDOM%$divisor))
        case $rand in
        0) printf "${chars[$RANDOM%$count]} " ;;
        1) printf "  " ;; # Maintain some blank space in the animation
        *) printf "\033[2C" ;; # move the cursor two spaces forward
        esac
      done
      printf "\n"
    done
    tput cup 0 0
  done

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #                       THIS IS WHERE THE MESSAGE ANIMATION BEGINS
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


  # Return the cursor to normal
  tput cnorm

  # Change font
  echo "\033[30m"

  text_entry=("forward" "reverse" "random")
  text_deletion=("reverse" "random" "overwrite")
  char_pause=0.1
  word_pause=0.18
  after_entry_pause=2
  after_deletion_pause=1
  final_pause=1

  # Terminal window parameters
  rows=`tput lines`
  columns=`tput cols`
  middle_line=`expr $rows / 2`
  center_column=`expr $columns / 2`

  line_index=0
  lines=('Hello World', 'I am Vikram', 'WITNESS ME')

  for line in "${lines[@]}"
  do

    # Compute line length.
    # Subtract 1 for the new line char
    line_length=`echo $line | wc -c`
    line_length=`expr $line_length - 1`

    # Compute cursor positioning
    home_position=`expr $center_column - $line_length / 2`
    end_position=`expr $home_position + $line_length`

    case ${text_entry[$line_index]} in

    forward)
      # Keep track of words for adding spaces
      word_count=`echo $line | wc -w`
      current_word=1

      # Position the cursor
      tput cup $middle_line $home_position

      for word in $line
      do
        # Print the characters of each word
        for (( char_index=0; char_index<${#word}; char_index++ ));
        do
          echo "${word:$char_index:1}\c"
          sleep $char_pause
        done

        # Add a space after all words except the last word
        if [ $current_word != $word_count ]
        then
          echo " \c"
          current_word=`expr $current_word + 1`
        fi

        sleep $word_pause

      done # word loop
      ;; # forward case

    reverse)
      # Position the cursor on the last character
      tput cup $middle_line `expr $end_position - 1`
      for (( i=`expr $line_length - 1`; i>=0; i-- ));
      do
        sleep $char_pause
        echo "${line:i:1}\b\b\c"
      done
      ;; # reverse case

    outside_in)
      # Make the cursor invisible
      tput civis

      for (( i=0; i<line_length; i++ ))
      do
        if [ `expr $i % 2` -eq 0 ] # even iterations
        then
          # Calculate index to enter
          text_index=`expr $i / 2`

          # Position cursor
          tput cup $middle_line `expr $home_position + $text_index`

          sleep $char_pause
          echo "${line:$text_index:1}\c"
        else # odd iterations
          # Calculate index to enter
          text_index=`expr $line_length - \( $i + 1 \) / 2`

          # Position cursor
          tput cup $middle_line `expr $home_position + $text_index`

          sleep $char_pause
          echo "${line:$text_index:1}\c"
        fi
      done

      # Position cursor
      tput cup $middle_line $end_position

      ;; # outside-in case

      inside_out)

        # Hide the cursor
        tput civis

        # Check if line length is even or odd
        if [ `expr $line_length % 2` -eq 0 ]
        then
          for (( i=0; i<$line_length; i++))
          do

            # Check if index is even or odd
            if [ `expr $i % 2` -eq 0 ]
            then
              text_index=`expr $line_length / 2 - \( $i + 2 \) / 2`
            else
              text_index=`expr $line_length / 2 + $i / 2`
            fi

            #Position the cursor. Enter the character
            tput cup $middle_line `expr $home_position + $text_index`
            sleep $char_pause
            echo "${line:$text_index:1}\c"

          done
        else
          for (( i=0; i<$line_length; i++))
          do
            # Check if index is even or odd
            if [ `expr $i % 2` -eq 0 ]
            then
              text_index=`expr $line_length / 2 - $i / 2`
            else
              text_index=`expr $line_length / 2 + \( $i + 1 \) / 2`
            fi

            #Position the cursor. Enter the character
            tput cup $middle_line `expr $home_position + $text_index`
            sleep $char_pause
            echo "${line:$text_index:1}\c"



          done
        fi

        # Position cursor
        tput cup $middle_line $end_position

      ;; # inside_out case

      random)
      # Create an array for positions
      # Randomly select from the positions array, since characters may be repeated

      # Populate the positions array
      for (( i=0; i<$line_length; i++ ))
      do
        position_array[$i]=$i
      done

      # Randomly select from the position array
      for (( i=0; i<$line_length; i++ ))
      do

        # Divisor needs to be one more than max index
        divisor=$line_length

        while true
        do

          # Generate a random index between 0 and max index
          random_index=$(($RANDOM%divisor))

          # Enter characters that have not already been entered
          if [ "${position_array[random_index]}" != "" ]
          then

            # Move cursor to position
            new_column=`expr $home_position + $random_index`
            tput cup $middle_line $new_column

            # Print character
            sleep $char_pause
            echo "${line:$random_index:1}\c"

            # Remove entry from position array
            unset position_array[random_index]

            # Break the while loop. Continue with the for loop
            break
          fi # Done printing character
        done # Done generating random indices

      done # Line printing done

      # Delete the array
      unset position_array

      # Relocate cursor to end of sentence
      tput cup $middle_line $end_position

      ;; # random case

    instant)
      tput civis
      tput cup $middle_line $home_position
      echo "$line\c"
      ;;

    *)
      echo "Invalid value for text entry"
      exit
      ;;

    esac # text entry

    sleep $after_entry_pause # Rest between text entry and deletion

    if [ ${text_entry[line_index]} = "instant" -o ${text_entry[line_index]} = "outside_in" -o ${text_entry[line_index]} = "inside_out" ]
    then
      tput cnorm # make the cursor visible
    fi

    case ${text_deletion[$line_index]} in

    forward)
      # Delete text from left to right
      tput cup $middle_line $home_position
      for (( i=0; i<line_length; i++ ))
      do
        echo " \c"
        sleep $char_pause
      done
      ;;

    reverse)
      # Place the cursor at the end of the line
      tput cup $middle_line $end_position

      # Delete the text from right to left
      for (( i=0; i<line_length; i++ ))
      do
        echo "\b \b\c"
        sleep $char_pause
      done
      ;;

    outside_in)
      # Make the cursor invisible
      tput civis

      for (( i=0; i<line_length; i++ ))
      do
        if [ `expr $i % 2` -eq 0 ] # even iterations
        then
          # Calculate index to enter
          text_index=`expr $i / 2`

          # Position cursor
          tput cup $middle_line `expr $home_position + $text_index`

          sleep $char_pause
          echo " \c"
        else # odd iterations
          # Calculate index to enter
          text_index=`expr $line_length - \( $i + 1 \) / 2`

          # Position cursor
          tput cup $middle_line `expr $home_position + $text_index`

          sleep $char_pause
          echo " \c"
        fi
      done

      # Position cursor
      tput cup $middle_line $end_position

      ;; # outside-in case

    inside_out)

        # Hide the cursor
        tput civis

        # Check if line length is even or odd
        if [ `expr $line_length % 2` -eq 0 ]
        then
          for (( i=0; i<$line_length; i++))
          do

            # Check if index is even or odd
            if [ `expr $i % 2` -eq 0 ]
            then
              text_index=`expr $line_length / 2 - \( $i + 2 \) / 2`
            else
              text_index=`expr $line_length / 2 + $i / 2`
            fi

            #Position the cursor. Enter the character
            tput cup $middle_line `expr $home_position + $text_index`
            sleep $char_pause
            echo " \c"

          done
        else
          for (( i=0; i<$line_length; i++))
          do
            # Check if index is even or odd
            if [ `expr $i % 2` -eq 0 ]
            then
              text_index=`expr $line_length / 2 - $i / 2`
            else
              text_index=`expr $line_length / 2 + \( $i + 1 \) / 2`
            fi

            #Position the cursor. Enter the character
            tput cup $middle_line `expr $home_position + $text_index`
            sleep $char_pause
            echo " \c"



          done
        fi

        # Position cursor
        tput cup $middle_line $end_position

      ;; # inside_out case

    random)
      # Delete the text in random order
      # Create an array for positions
      # Randomly select from the positions array, since characters can repeat themselves

      # Populate the positions array
      for (( i=0; i<$line_length; i++ ))
      do
        position_array[$i]=$i
        # echo "Position $i is ${position_array[$i]}"
      done

      # Randomly select from the position array
      for (( i=0; i<$line_length; i++ ))
      do

        # Divisor needs to be one more than max index
        divisor=$line_length

        while true
        do

          # Generate a random index between 0 and line_length - 1
          random_index=$(($RANDOM%divisor))

          # Enter characters that have not already been entered
          if [ "${position_array[random_index]}" != "" ]
          then

            # Move cursor to position
            new_column=`expr $home_position + $random_index`
            tput cup $middle_line $new_column

            # Delete character by overwriting it with a space
            sleep $char_pause
            echo " \c"

            # Remove entry from position array
            unset position_array[random_index]

            # Break the while loop. Continue with the for loop
            break
          fi # Done printing character
        done # Done generating random indices

      done # Line printing done

      # Delete the array
      unset position_array
      ;;

    overwrite)
      # Overwrite the previous line of text.
      # Be sure to increment line_number before leaving the loop
      line_index=`expr $line_index + 1`
      continue
      ;;

    instant)

      tput civis

      # Place the cursor at the end of the line
      tput cup $middle_line $end_position

      # Delete the text from right to left
      for (( i=0; i<line_length; i++ ))
      do
        echo "\b \b\c"
      done
      ;;

    *)
      echo "Invalid value for text deletion"
      exit
      ;;

    esac # text deletion

    sleep $after_deletion_pause

    if [ ${text_deletion[line_index]} = "instant" -o ${text_deletion[line_index]} = "outside_in" -o ${text_deletion[line_index]} = "inside_out" ]
    then
      tput cnorm # make the cursor visible
    fi

    line_index=`expr $line_index + 1`

  done # while read line

  sleep $final_pause

  # Font Reset
  echo "\033[0;0m"

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #                    THIS IS WHERE THE FINAL ANIMATION BEGINS
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  # Hide and position the cursor
  tput civis
  tput cup 0 0

  # Terminal window parameters
  screenlines=$(expr `tput lines` - 1 + $outro_scroll_speed)

  for(( x=0; x<60; x++ ))
  do
    for i in $(eval echo {1..$screenlines})
    do
      for i in $(eval echo {1..$screencols})
      do
        rand=$(($RANDOM%$divisor))
        case $rand in
        0)
          case $ending in
          fade) printf "  " ;; # Fade out
          repopulate) printf "${chars[$RANDOM%$count]} " ;;
          *) echo "Invalid ending parameter"; exit ;;
          esac ;;
        1) printf "  " ;; # Maintain some blank space in the animation
        *) printf "\033[2C" ;; # move the cursor two spaces forward
        esac
      done
      printf "\n"
    done
    tput cup 0 0
  done

}

init()
