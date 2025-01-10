#! /bin/bash
# Install openCV 4.10.0 on Ubuntu 22.04 Jammy

# Copyright 2025 mkdir-sweetiepie
# https://github.com/mkdir-sweetiepie/opencv_install
# Licensed under the Apache License 2.0

function custom_echo() {
  text=$1                     # 첫 번째 인자는 출력할 텍스트입니다.
  color=$2                    # 두 번째 인자는 출력할 색상입니다.

  case $color in
  "red")
    echo -e "\033[31m[RO:BIT] $text\033[0m" # 빨간색으로 출력
    ;;
  "green")
    echo -e "\033[32m[RO:BIT] $text\033[0m" # 초록색으로 출력
    ;;
  "yellow")
    echo -e "\033[33m[RO:BIT] $text\033[0m" # 노란색으로 출력
    ;;
  *)
    echo "$text"
    ;;
  esac
}

loading_animation() {
  local interval=1                                    # 프레임 전환 간격을 설정 (0.1초 단위, 0.1초로 표시됨)
  local duration=30                                   # 애니메이션 총 지속 시간 (초 단위)
  local bar_length=$(tput cols)                       # 터미널 창의 너비를 가져옴
  local total_frames=$((duration * interval))         # 총 프레임 수를 계산
  local frame_chars=("█" "▉" "▊" "▋" "▌" "▍" "▎" "▏") # 로딩 애니메이션에 사용할 프레임 문자 배열

  for ((i = 0; i <= total_frames; i++)); do
    local frame_index=$((i % ${#frame_chars[@]}))     # 현재 프레임 문자 인덱스를 계산
    local progress=$((i * bar_length / total_frames)) # 진행 상황을 터미널 너비로 변환
    local bar=""
    for ((j = 0; j < bar_length; j++)); do
      if ((j <= progress)); then
        bar+="${frame_chars[frame_index]}" # 진행된 부분에 해당하는 프레임 문자 추가
      else
        bar+=" " # 진행되지 않은 부분에는 공백 추가
      fi
    done
    printf "\r\033[32m%s\033[0m" "$bar" # 초록색으로 출력
    sleep 0.$interval                   # 다음 프레임까지 대기 (여기서는 0.1초)
  done

  printf "\n"
}

text_art="

░█▀▀█ ░█▀▀▀█ ▄ ░█▀▀█ ▀█▀ ▀▀█▀▀ 　 ░█▀▄▀█ ░█─▄▀ ░█▀▀▄ ▀█▀ ░█▀▀█ 
░█▄▄▀ ░█──░█ ─ ░█▀▀▄ ░█─ ─░█── 　 ░█░█░█ ░█▀▄─ ░█─░█ ░█─ ░█▄▄▀ 
░█─░█ ░█▄▄▄█ ▀ ░█▄▄█ ▄█▄ ─░█── 　 ░█──░█ ░█─░█ ░█▄▄▀ ▄█▄ ░█─░█ 

░█▀▀▀█ ░█──░█ ░█▀▀▀ ░█▀▀▀ ▀▀█▀▀ ▀█▀ ░█▀▀▀ ░█▀▀█ ▀█▀ ░█▀▀▀ 
─▀▀▀▄▄ ░█░█░█ ░█▀▀▀ ░█▀▀▀ ─░█── ░█─ ░█▀▀▀ ░█▄▄█ ░█─ ░█▀▀▀ 
░█▄▄▄█ ░█▄▀▄█ ░█▄▄▄ ░█▄▄▄ ─░█── ▄█▄ ░█▄▄▄ ░█─── ▄█▄ ░█▄▄▄ 

░█▀▀█ ░█▀▀▀█ ░█▀▀▀█ 
░█▄▄▀ ░█──░█ ─▀▀▀▄▄ 
░█─░█ ░█▄▄▄█ ░█▄▄▄█

"

terminal_width=$(tput cols)                             # 현재 터미널의 너비(컬럼 수)를 가져옵니다.
padding_length=$(((terminal_width - ${#text_art}) / 2)) # 중앙 패딩
padding=$(printf "%*s" $padding_length "")

echo -e "\033[38;5;208m$padding$text_art\033[0m"           # 텍스트 아트 출력
custom_echo "GITHUB : github.com/mkdir-sweetiepie" "green" # 깃헙 주소 출력
custom_echo "RO:BIT 18th JiHyeon Hong" "green"             # 이름 출력
custom_echo "Install opencv" "green"                  #  설치 정보 출력

# Check OpenCV version
opencv_version=$(pkg-config --modversion opencv 2>/dev/null)
opencv4_version=$(pkg-config --modversion opencv4 2>/dev/null)

if [ ! -z "$opencv_version" ] || [ ! -z "$opencv4_version" ]; then
    custom_echo "Found existing OpenCV installation:" "yellow"
    [ ! -z "$opencv_version" ] && custom_echo "OpenCV: $opencv_version" "yellow"
    [ ! -z "$opencv4_version" ] && custom_echo "OpenCV4: $opencv4_version" "yellow"
    
    read -p "Do you want to remove existing OpenCV installation? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        custom_echo "Removing existing OpenCV..." "yellow"
        sudo apt-get purge opencv* -y
        sudo apt-get purge libopencv* -y
        sudo apt-get autoremove -y
        sudo find /usr/local/ -name "*opencv*" -exec rm -i {} \;
        custom_echo "Existing OpenCV removed successfully" "green"
    else
        custom_echo "Keeping existing OpenCV installation" "yellow"
    fi
fi

loading_animation

custom_echo "Updating package lists..." "green"
sudo apt update && sudo apt upgrade -y

custom_echo "Installing package..." "green"
sudo apt-get install -y build-essential cmake pkg-config
sudo apt-get install -y libjpeg-dev libtiff5-dev libpng-dev
sudo apt-get install -y ffmpeg libavcodec-dev libavformat-dev libswscale-dev libxvidcore-dev libx264-dev libxine2-dev
sudo apt-get install -y libv4l-dev v4l-utils
sudo apt-get install -y libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev
sudo apt-get install -y libgtk-3-dev
sudo apt-get install -y qtbase5-dev
sudo apt-get install -y mesa-utils libgl1-mesa-dri libgtkglext1-dev
sudo apt-get install -y libatlas-base-dev gfortran libeigen3-dev
sudo apt-get install -y python3-dev python3-numpy python3-pip cmake
sudo apt-get install -y libopencv-dev
custom_echo "package installed successfully!" "green"

custom_echo "Building OpenCV from source..." "green"
mkdir -p /home/$USER/opencv
cd /home/$USER/opencv
wget -O opencv.zip https://github.com/opencv/opencv/archive/4.10.0.zip
unzip opencv.zip
wget -O opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/4.10.0.zip
unzip opencv_contrib.zip
cd opencv-4.10.0
mkdir -p build
cd build
custom_echo "Configuring OpenCV build..." "green"

cmake \
    -D CMAKE_BUILD_TYPE=RELEASE \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D WITH_TBB=OFF \
    -D WITH_IPP=OFF \
    -D WITH_1394=OFF \
    -D BUILD_WITH_DEBUG_INFO=OFF \
    -D BUILD_DOCS=OFF \
    -D INSTALL_C_EXAMPLES=OFF \
    -D INSTALL_PYTHON_EXAMPLES=OFF \
    -D BUILD_EXAMPLES=OFF \
    -D BUILD_PACKAGE=OFF \
    -D BUILD_TESTS=OFF \
    -D BUILD_PERF_TESTS=OFF \
    -D WITH_QT=ON \
    -D WITH_GTK=ON \
    -D WITH_OPENGL=ON \
    -D BUILD_opencv_python3=ON \
    -D OPENCV_EXTRA_MODULES_PATH=/home/$USER/opencv/opencv_contrib-4.10.0/modules \
    -D WITH_V4L=ON \
    -D WITH_FFMPEG=ON \
    -D WITH_XINE=ON \
    -D OPENCV_ENABLE_NONFREE=ON \
    -D BUILD_NEW_PYTHON_SUPPORT=ON \
    -D OPENCV_SKIP_PYTHON_LOADER=ON \
    -D OPENCV_GENERATE_PKGCONFIG=ON \
    ..
custom_echo "OpenCV build configured successfully!" "green"

custom_echo "Building OpenCV..." "green"
make -j$(nproc)

custom_echo "Installing OpenCV..." "green" 
sudo make install
sudo ldconfig

custom_echo "Installation complete!" "green"
custom_echo "Please restart your computer to complete the installation" "green"
loading_animation

exit 0
