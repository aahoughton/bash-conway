#!/usr/bin/env bash

COLS=0
ROWS=0
INDEX=0

live_test () {
	if [[ $1 -lt 1 ]]; then return 0; fi
	if [[ $1 -gt ${COLS} ]]; then return 0; fi
	if [[ $2 -lt 1 ]]; then return 0; fi
	if [[ $2 -gt ${ROWS} ]]; then return 0; fi

	if [[ ${CURR_BOARD[$(( ($2 - 1) * $COLS + ( $1 - 1 ) ))]} == '.' ]]; then
		return 0
	fi

	return 1
}

# read
while read line; do
  ROWS=$(( $ROWS + 1 ))
  [[ $COLS -eq 0 ]] && COLS=${#line}
  [[ $COLS -ne ${#line} ]] && echo "inconsistent column count on row $ROWS" && exit 1
  if ! [[ $line =~ [#.]+ ]]; then 
  	echo "cell is neither # (live) nor . (dead) on row $ROWS"
  	exit 1
  fi
  for (( i=0 ; i < ${#line} ; i++ )); do 
  	CURR_BOARD[INDEX]=${line:i:1}
  	INDEX=$(( $INDEX + 1 ))
  done
done < "${1:-/dev/stdin}"

# evolve
for (( y=1; y <= $ROWS ; y++ )); do
	for (( x=1; x <= $COLS ; x++ )); do
		INDEX=$(( ($y - 1) * $COLS + ( $x - 1 ) ))
		CURR=${CURR_BOARD[$INDEX]}

		live_test $(( x - 1 )) $(( y - 1 )); COUNT=$?
		live_test $(( x ))     $(( y - 1 )); COUNT=$(( $COUNT + $? ))
		live_test $(( x + 1 )) $(( y - 1 )); COUNT=$(( $COUNT + $? ))

		live_test $(( x - 1 )) $(( y ))    ; COUNT=$(( $COUNT + $? ))
		live_test $(( x + 1 )) $(( y ))    ; COUNT=$(( $COUNT + $? ))

		live_test $(( x - 1 )) $(( y + 1 )); COUNT=$(( $COUNT + $? ))
		live_test $(( x )) $(( y + 1 ))    ; COUNT=$(( $COUNT + $? ))
		live_test $(( x + 1 )) $(( y + 1 )); COUNT=$(( $COUNT + $? ))

		if [ $CURR == '#' ] && [ $COUNT -eq 2 -o $COUNT -eq 3 ]; then
			NEXT_BOARD[$INDEX]='#'
		elif [ $CURR == '.' ] && [ $COUNT -eq 3 ]; then
			NEXT_BOARD[$INDEX]='#'
		else
			NEXT_BOARD[$INDEX]='.'
		fi
	done
done

# write
for (( i=0; i < ${#NEXT_BOARD[@]} ; i++ )); do
	echo -n ${NEXT_BOARD[$i]}
	[[ $(( ($i + 1) % COLS )) -eq 0 ]] && echo ''
done
