# Copyright (c) 2019 TOYOTA MOTOR CORPORATION
# Copyright (c) 2021 MID Academic Promotions, Inc.
# All rights reserved.

# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:

#  * Redistributions of source code must retain the above copyright notice,
#  this list of conditions and the following disclaimer.
#  * Redistributions in binary form must reproduce the above copyright
#  notice, this list of conditions and the following disclaimer in the
#  documentation and/or other materials provided with the distribution.
#  * Neither the name of Toyota Motor Corporation nor the names of its
#  contributors may be used to endorse or promote products derived from
#  this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
FROM ros:melodic

SHELL ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install -y curl apt-transport-https python-pip && \
    apt-get clean

# OSRF distribution is better for gazebo
RUN sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list' && \
    curl -L http://packages.osrfoundation.org/gazebo.key | apt-key add -

# install depending packages
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y \
    ros-melodic-gazebo-ros ros-melodic-gazebo-plugins ros-melodic-gazebo-ros-control libgazebo9-dev libignition-transport4-dev libpoco-dev python-scipy libgsl-dev \
    ros-melodic-dwa-local-planner \
    ros-melodic-eigen-conversions \
    ros-melodic-robot-state-publisher \
    ros-melodic-moveit-core \
    ros-melodic-moveit-plugins \
    ros-melodic-moveit-planners-ompl \
    ros-melodic-moveit-ros-planning \
    ros-melodic-moveit-ros-move-group \
    ros-melodic-moveit-ros-manipulation \
    ros-melodic-moveit-simple-controller-manager \
    ros-melodic-urdfdom-py \
    ros-melodic-roslint \
    ros-melodic-joint-state-controller \
    ros-melodic-joint-trajectory-controller \
    ros-melodic-move-base \
    ros-melodic-map-server \
    ros-melodic-xacro \
    ros-melodic-joint-state-publisher \
    liburdfdom-tools \
    ros-melodic-image-proc \
    ros-melodic-depth-image-proc \
    ros-melodic-effort-controllers \
    ros-melodic-ros-controllers \
    ros-melodic-pcl-ros \
    ros-melodic-tf-conversions \
    ros-melodic-moveit-ros-perception && \
    pip install -U --ignore-installed pyassimp supervisor supervisor_twiddler && \
    apt-get autoremove -y && \
    apt-get clean

RUN mkdir /ws
ADD src /ws/src
RUN cd /ws/src && source /opt/ros/$ROS_DISTRO/setup.bash && catkin_init_workspace || true
#RUN cd /ws && source /opt/ros/$ROS_DISTRO/setup.bash && rosdep update && rosdep install --from-paths src --ignore-src -r -y
RUN cd /ws && source /opt/ros/$ROS_DISTRO/setup.bash && catkin_make install -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/opt/ros/$ROS_DISTRO -DCATKIN_ENABLE_TESTING=0

ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

ADD supervisord.conf /etc/supervisor/supervisord.conf

VOLUME [ \
    "/opt/ros/melodic/share/hsrb_description", \
    "/opt/ros/melodic/share/hsrb_meshes", \
    "/opt/ros/melodic/share/gazebo_ros", \
    "/opt/ros/melodic/lib/gazebo_ros", \
    "/opt/ros/melodic/lib/python2.7/dist-packages/gazebo_ros", \
    "/opt/ros/melodic/lib/python2.7/dist-packages/gazebo_msgs", \
    "/opt/ros/melodic/share/hsrb_rosnav_config", \
    "/opt/ros/melodic/share/tmc_control_msgs", \
    "/opt/ros/melodic/lib/python2.7/dist-packages/tmc_control_msgs", \
    "/opt/ros/melodic/include/tmc_control_msgs" \
    ]

CMD ["/usr/local/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]

