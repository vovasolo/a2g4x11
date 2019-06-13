FROM ants2-x11

ARG G4VERSION=10.5.1
ARG JOBS=14

# additional libs needed by GEANT
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get -y install libxerces-c-dev freeglut3-dev libmotif-dev tk-dev libxpm-dev libxmu-dev libxi-dev

# GEANT Installation
RUN wget https://github.com/Geant4/geant4/archive/v$G4VERSION.tar.gz
RUN tar -xzf v$G4VERSION.tar.gz -C /opt
RUN rm v$G4VERSION.tar.gz

RUN mkdir /geant4-build # refresh+1!
# build Geant4 
# NB: building a *single-threaded* version
# change DGEANT4_BUILD_MULTITHREADED to ON if feeling adventurous
RUN cd /geant4-build && cmake -DCMAKE_INSTALL_PREFIX=/opt/geant4-install -DGEANT4_USE_GDML=ON -DCMAKE_BUILD_TYPE=Release -DGEANT4_INSTALL_DATA=ON -DGEANT4_USE_OPENGL_X11=ON -DGEANT4_USE_XM=ON -DGEANT4_USE_QT=ON -DGEANT4_BUILD_MULTITHREADED=OFF /opt/geant4-$G4VERSION && make -j$JOBS && make install
RUN echo ". /opt/geant4-install/bin/geant4.sh" >> ~/.bashrc
#RUN echo ". /opt/geant4-install/bin/geant4.sh" > /etc/profile.d/geant4.sh && chmod +x /etc/profile.d/geant4.sh

# cleanup
RUN rm -rf /geant4-build
RUN rm -rf /opt/geant4-$G4VERSION
# End of GEANT4 stuff

# G4ants
RUN cd / && git clone https://github.com/andrmor/G4ants.git # refresh+1!
RUN cd /G4ants  && cmake . && make -j$JOBS && make install

#ENV LD_LIBRARY_PATH=/opt/root/lib:/ncrystal
COPY startup.sh /root/
ENTRYPOINT ["/root/startup.sh"]


