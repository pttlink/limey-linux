#! /bin/sh                                                                      
TOPDOMAIN=allstarlink.org                                                       
WGET=`which wget`

for i in nodes1 nodes2 nodes3 nodes4
do                                                               
	$WGET  -q -O /tmp/$i.out http://$i.$TOPDOMAIN/cgi-bin/nodes.pl
	if [ $? -ne 0 ]
	then
		echo "$i.$TOPDOMAIN is down"
	else
		echo "$i.$TOPDOMAIN is up"
		sites=$((sites+1))
		if [ -z "$nodelist" ]
		then
			nodelist=$i 
		else
			nodelist="$nodelist $i"
		fi

	fi
done

if ! [ -z $1 ]
then
	cnt=1
	while [ $cnt -lt $((sites + 1)) ]
	do
		echo "***** nodes$cnt *****"
		grep $1 < /tmp/nodes$cnt.out
		cnt=$((cnt+1))
	done
else
	cnt=1
	while [ $cnt -lt $((sites + 1)) ]
	do
		echo "***** nodes$cnt *****"
		head -n 3 /tmp/nodes$cnt.out
		cnt=$((cnt+1))
	done
fi

rm /tmp/nodes*.out
