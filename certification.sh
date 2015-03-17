#!/bin/bash
# opensl certification

#set -x

ROOT_KEY="/root/certs/rootCA.key"
ROOT_CRT="/root/certs/rootCA.crt"

# Generate Key
function gen_key
{
    local bitlen="2048"
    local filename="rsa.key"
    local pass="y"
    
    local defaultval
    local input
    
    # Bits
    defaultval=$bitlen;    
    read -e -p "Enter length of the key [$defaultval]: " input
    bitlen="${input:=$defaultval}"
    
    # Filename
    defaultval=$filename;    
    read -e -p "Enter output file [$defaultval]: " input
    filename="${input:=$defaultval}"
    
    # Passphrase
    defaultval=$pass
    read -e -p "Encrypt with password? [$defaultval]: " input
    pass="${input:=$defaultval}"
    
    # Create
    if [ "y" == "$pass" ]
    then
        openssl genrsa -aes128 -passout stdin -out $filename $bitlen
    else 
        openssl genrsa -out $filename $bitlen
    fi    
}

# Generate Certificate
function gen_cert
{
    local filename="req.csr"
    local keyname="rsa.key"
        
    local defaultval
    local input
    
    # Keyname
    defaultval=$keyname;    
    read -e -p "Enter key file name [$defaultval]: " input
    keyname="${input:=$defaultval}"
    
    # Filename
    defaultval=$filename;    
    read -e -p "Enter output file [$defaultval]: " input
    filename="${input:=$defaultval}"
    
    # Create
    openssl req -new -key $keyname -out $filename       
}

# Sign certificate
function sign
{
    local rootkey="$ROOT_KEY"
    local rootcrt="$ROOT_CRT"
    local incrt="req.csr"
    local out="out.crt"
    local expiry="365"
        
    local defaultval
    local input
    
    # Rootkey
    defaultval="$rootkey";    
    read -e -p "Enter root key file [$defaultval]: " input
    rootkey="${input:=$defaultval}"
    
    # Rootcrt
    defaultval="$rootcrt";    
    read -e -p "Enter root certificate file [$defaultval]: " input
    rootcrt="${input:=$defaultval}"

    # Request cert
    defaultval="$incrt";    
    read -e -p "Enter request certificate [$defaultval]: " input
    incrt="${input:=$defaultval}"
    
    # Output certificate    
    defaultval="$out";    
    read -e -p "Enter output certificate file name [$defaultval]: " input
    out="${input:=$defaultval}"
    
    # Expiration
    defaultval="$expiry";    
    read -e -p "Enter expiration in days [$defaultval]: " input
    expiry="${input:=$defaultval}"
    
    # Sign
    openssl x509 -req -in $incrt -CA $rootcrt -CAkey $rootkey -CAcreateserial -out $out -days $expiry
}

# Generate self-signed certificate
function gen_ca
{
    local rootkey="rsa.key"    
    local out="out.crt"
    local expiry="1024"
        
    local defaultval
    local input
    
    # Rootkey
    defaultval="$rootkey";    
    read -e -p "Enter root key file [$defaultval]: " input
    rootkey="${input:=$defaultval}"
    
    # Output certificate    
    defaultval="$out";    
    read -e -p "Enter output certificate file name [$defaultval]: " input
    out="${input:=$defaultval}"
    
    # Expiration
    defaultval="$expiry";    
    read -e -p "Enter expiration in days [$defaultval]: " input
    expiry="${input:=$defaultval}"

    # Generate
    openssl req -x509 -new -nodes -key $rootkey -days $expiry -out $out
}

# Generate p12 certificate
function gen_p12
{
    local key="rsa.key"  
    local crt="in.crt"
    local out="out.p12"
        
    local defaultval
    local input
    
    # Key
    defaultval="$key";    
    read -e -p "Enter input key file [$defaultval]: " input
    key="${input:=$defaultval}"
    
    # Cert
    defaultval="$crt";    
    read -e -p "Enter input certificate file [$defaultval]: " input
    crt="${input:=$defaultval}"
    
    # Rootcrt
    defaultval="$rootcrt";    
    read -e -p "Enter root certificate file [$defaultval]: " input
    rootcrt="${input:=$defaultval}"
    
        
    # Generate
    openssl pkcs12 -export -out $out -inkey $key -in $crt
}

until false; do
    PS3="Please enter your choice: "
    select opt in "Generate Key"\
     "Generate Certificate" "Sign Certificate"\
     "Generate Self-signed Certificate" "Generate p12 Certificate" "Exit"
    do
        case $opt in
            "Generate Key")
                gen_key
                ;;
            "Generate Certificate")
                gen_cert
                ;;
            "Sign Certificate")
                sign
                ;;
            "Generate Self-signed Certificate")
                gen_ca
                ;;
            "Generate p12 Certificate")
                gen_p12
                ;;
            "Exit")
                exit
                ;;
            *) echo invalid option;;
        esac
        break
     done
 done


