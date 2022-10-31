#!/bin/bash

apt update

if ! command -v go &>/dev/null; then
wget https://go.dev/dl/go1.18.linux-amd64.tar.gz && rm -rf /usr/local/go && tar -C /usr/local -xzf go1.18.linux-amd64.tar.gz && cp /usr/local/go/bin/go /usr/local/bin/
else
	echo "Go Already Installed"
fi

if ! command -v amass &>/dev/null; then
go install -v github.com/OWASP/Amass/v3/...@master
else
        echo "Amass Already Installed"
fi

if ! command -v subfinder &>/dev/null; then
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest && cp /root/go/bin/subfinder /usr/local/bin/
else
        echo "Subfinder Already Installed"
fi
if ! command -v aquatone &>/dev/null; then
wget https://github.com/michenriksen/aquatone/releases/download/v1.7.0/aquatone_linux_amd64_1.7.0.zip -O /tmp/aquatone_linux_amd64.zip && unzip -a /tmp/aquatone_linux_amd64.zip -d /tmp && cp /tmp/aquatone /usr/local/bin
else
        echo "Aquatone Already Installed"
fi
	
if ! command -v chromium &>/dev/null; then
sudo apt install chromium -y
else
        echo "Chromium Already Installed"
fi

if ! command -v httpx &>/dev/null; then
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest && cp /root/go/bin/httpx /usr/local/bin/
else
        echo "HTTPx Already Installed"
fi

if ! command -v nuclei &>/dev/null; then
go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest && cp /root/go/bin/nuclei /usr/local/bin/
else
        echo "Nuclei Already Installed"
fi

if ! command -v dnsx &>/dev/null; then
go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest  && cp /root/go/bin/dnsx /usr/local/bin/
else
        echo "Dnsx Already Installed"
fi

if ! command -v hakrawler &>/dev/null; then
go install github.com/hakluke/hakrawler@latest  && cp /root/go/bin/hakrawler /usr/local/bin/
else
        echo "hakrawler Already Installed"
fi
