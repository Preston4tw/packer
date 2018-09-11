echo "Running: groupadd $NEWUSERLOGIN"
groupadd "$NEWUSERLOGIN"
echo "Done.."

sleep 2

echo "Running: usermod -d /home/$NEWUSERLOGIN -m -l $NEWUSERLOGIN -g $NEWUSERLOGIN -c $NEWUSERFULLNAME vagrant"
usermod -d /home/"$NEWUSERLOGIN" -m -l "$NEWUSERLOGIN" -g "$NEWUSERLOGIN" -c "$NEWUSERFULLNAME" vagrant
echo "Done.."

sleep 3

echo "Setting up passwordless sudo for $NEWUSERLOGIN"
echo "$NEWUSERLOGIN ALL=(ALL) NOPASSWD: ALL" | tee "/etc/sudoers.d/$NEWUSERLOGIN" &>/dev/null
echo "Done.."

sleep 3

# fix symlink for IntelliJ
echo "Fixing Intellij launcher symlink"
EXTRACTDIR="$(dirname $(tar -ztf "/home/${NEWUSERLOGIN}/${INTELLIJ_FILENAME}" | head -n1))"
ln -sf "/home/${NEWUSERLOGIN}/${EXTRACTDIR}/bin/idea.sh" "/home/${NEWUSERLOGIN}/IntelliJ_launcher"
echo "Done"

sleep 3

# fix symlink for netbeans
echo "Fixing Netbeans launcher symlink"
ln -sf "/home/${NEWUSERLOGIN}/netbeans-8.2/bin/netbeans" "/home/${NEWUSERLOGIN}/netbeans8.2_launcher"
echo "Done"

echo "Renamed vagrant to $NEWUSERLOGIN"
