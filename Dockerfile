FROM mcr.microsoft.com/windows/servercore:ltsc2022

LABEL maintainer="sosorio@morrisopazo.com"

ENV ssrs_url "https://download.microsoft.com/download/1/a/a/1aaa9177-3578-4931-b8f3-373b24f63342/SQLServerReportingServices.exe"
ENV ssrs_args "/quiet /IAcceptLicenseTerms /Edition=dev"

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

RUN Invoke-WebRequest -Uri $Env:ssrs_url -OutFile SSRS.exe; \
    Start-Process SSRS -Wait -ArgumentList $Env:ssrs_args; \
    Remove-Item SSRS.exe

COPY *.dll ./Windows/System32/

COPY *.ps1 .

CMD ./config
