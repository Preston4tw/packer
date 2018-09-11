#!/bin/bash -x

echo "Doing echo $AWS_ACCESS_KEY_ID > /home/$NEWUSERLOGIN/.awssecret"
echo $AWS_ACCESS_KEY_ID > /home/$NEWUSERLOGIN/.awssecret
echo "Done.."

echo "Doing $AWS_SECRET_ACCESS_KEY >> /home/$NEWUSERLOGIN/.awssecret"
echo $AWS_SECRET_ACCESS_KEY >> /home/$NEWUSERLOGIN/.awssecret # note >> for append
echo "Done.."

echo "Doing echo -ne $AZURE_SECRET > /home/$NEWUSERLOGIN/.azuresecret"
echo -ne $AZURE_SECRET > /home/$NEWUSERLOGIN/.azuresecret
echo "Done.."

echo "Doing chmod 600 /home/$NEWUSERLOGIN/.azuresecret"
chmod 600 /home/$NEWUSERLOGIN/.azuresecret
echo "Done.."

echo "Doing rm -rf /home/$NEWUSERLOGIN/.ssh/*"
rm -rf /home/$NEWUSERLOGIN/.ssh/*
echo "Done.."

echo "Creating ssh keys for $NEWUSERLOGIN"
ssh-keygen -f /home/$NEWUSERLOGIN/.ssh/id_rsa -N ""
echo "Done.."

echo "Setting up ~/.ssh/config for $NEWUSERLOGIN"
echo -e "\nHost $SVN_SERVER_URL svn1 svn\n  User=$NEWUSERLOGIN" >> /home/$NEWUSERLOGIN/.ssh/config
echo "Done.."

echo "Doing chmod 600 /home/$NEWUSERLOGIN/.ssh/config"
chmod 600 /home/$NEWUSERLOGIN/.ssh/config
echo "Done.."

echo "Set up Publickey based ssh login to self"
cat /home/$NEWUSERLOGIN/.ssh/id_rsa.pub >> /home/$NEWUSERLOGIN/.ssh/authorized_keys
echo "Done.."

echo "User \"$NEWUSERLOGIN\" with full name \"$NEWUSERFULLNAME\" created successfully"
