FROM fedora:34
# Install everything needed
RUN dnf -y install git python3 python3-devel python3-pip ncurses-devel gcc
ADD --chown=root:root ./entrypoint.sh /entrypoint.sh
run chmod 700 /entrypoint.sh 

# Run the job MUST use exec format to pass parameters
ENTRYPOINT ["/entrypoint.sh"]

