#!/usr/bin/env bash

# variables
user_input="$1"
second_arg="$2"
version="v1.0"
script_name="$0"
config_file="client.conf"
key_path="private_keys"

# color code
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
EC="\e[0m"

# functions starts
# checks if ssh agent is installed
check_ssh_agent(){
	if [[ $(which ssh-agent) ]]
	then
		printf "preparing ssh_agent...\n"
		${f_ssh_agent_init}
	else
		printf "ssh_agent not installed, installing..."
		${f_install_ssh_agent}
	fi
}

f_check_ssh_agent=check_ssh_agent


# installs ssh if not installed
install_ssh_agent(){
	if [[ $(id -u) == '0' ]]
	then
		printf "${RED}required root permission to install ssh_agent!${EC}\n"
	else
		apt update && apt install openssh-client
		printf "${GREEN}ssh-agent installed${EC}\n"
		${f_create_connection}
	fi

}
f_install_ssh_agent=install_ssh_agent

# shows the active ssh-agent connection
status_agent(){
	find_agent_status="$(ps -ely | grep ssh-agent)"
	ange_active_status="$(which ssh)"

	if [[ ${find_agent_status} ]]
	then
		
		printf "active ssh-agent session: ${GREEN}${find_agent_status}${EC}\n"
	else
		printf "no active ssh-agent session found!\n"
	fi
}
f_status_agent=status_agent

# connect
connect(){
	echo "connecting.."
}
f_connect=connect

# find server name in config_file
find_server(){
	echo "$(cat ${config_file} | grep -w ${second_arg}| cut -d ':' -f 4)"
}
f_find_server=find_server

#server username
server_name_user(){
	echo "$(cat ${config_file} | grep -w ${second_arg}| cut -d ':' -f 1)"
}
f_server_name_user=server_name_user

# server ip
server_name_ip(){
	echo "$(cat ${config_file} | grep -w ${second_arg}| cut -d ':' -f 2)"
}
f_server_name_ip=server_name_ip

# server private key
server_name_key(){
	echo "$(cat ${config_file} | grep -w ${second_arg}| cut -d ':' -f 3)"
}
f_server_name_key=server_name_key

# server private key
server_name(){
	echo "$(cat ${config_file} | grep -w ${second_arg}| cut -d ':' -f 4)"
}
f_server_name=server_name


# prints help
help(){
printf "${YELLOW}options\t\tdetails${EC}"
echo -e "
install		: installs the open-ssh service on host (${RED}required root permission${EC})
status		: shows the ssh service status and active ssh-agent connections
help <option>	: shows this help
connect	<name>	: connect with provided ip_address and ssh-key
connect_all	: connect all remot-host with ${config_file} file
down <name>	: down the ssh-agent by the name
downl_all	: down all of the ssh-agent with ${config_file} file
"
}
f_help=help
# function ends

# commands starts
case "$user_input" in
"status")
	printf "${YELLOW}${script_name}${EC}\n\n"
	printf "required plugins state: \nssh:\t\t[] \nkonsole:\t[]\n"

;;
"connect")
	# takes second_arg as server name input (filters ip from client.conf)
	if [[ ! -z ${second_arg} ]]
	then
		if [[ ! -z ${f_find_server} ]]
		then
			printf "found ${GREEN}${second_arg}${EC} server, connecting...\n"
                	#$(konsole -e ssh ${f_server_name_user}@${f_server_name_ip})
			echo -e "server:[ ${GREEN}$(${f_server_name_user})@$(${f_server_name_ip})${EC} ]\n"
			# continue here (test key file)
		else
			printf "${RED}no server found in client.conf${EC}, please enter user_name@ip_address\n"
                	read -p "enter user_name@ip_address: " uip
			 # uip (user ip addr)
                	if [[ -z ${uip} ]]
                	then
                        	echo "invalid input"
                	else
                        	ssh ${uip}
                	fi
		fi
	else
		printf "${RED}no server_name was provided${EC}, try $0 help for the help\n"
	fi

;;

"test")
	${f_find_server}
;;
"help")
	${f_help}
;;
"-h")
	${f_help}
;;
*)
	printf "${RED}invalid command${EC}, available options:\n\n"
	sleep 0.3
	${f_help}
esac
