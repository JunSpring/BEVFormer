ARG PYTORCH="1.9.0"
ARG CUDA="11.1"
ARG CUDNN="8"

FROM pytorch/pytorch:${PYTORCH}-cuda${CUDA}-cudnn${CUDNN}-devel

# 1. 환경 변수 설정 (RTX 40 시리즈 호환 및 CUDA 경로 설정)
ENV TORCH_CUDA_ARCH_LIST="6.0 6.1 7.0 7.5 8.0 8.6+PTX" \
    TORCH_NVCC_FLAGS="-Xfatbin -compress-all" \
    CMAKE_PREFIX_PATH="$(dirname $(which conda))/../" \
    FORCE_CUDA="1" \
    DEBIAN_FRONTEND=noninteractive

# 2. GPG 키 에러 해결 및 필수 시스템 패키지 설치
RUN rm /etc/apt/sources.list.d/cuda.list || true \
    && rm /etc/apt/sources.list.d/nvidia-ml.list || true \
    && apt-key del 7fa2af80 || true \
    && apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/3bf863cc.pub \
    && apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64/7fa2af80.pub \
    && apt-get update && apt-get install -y \
    ffmpeg libsm6 libxext6 git ninja-build libglib2.0-0 libxrender-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 3. Conda 가상환경 생성 및 기본 쉘 설정
RUN conda create -n open-mmlab python=3.8 -y
SHELL ["conda", "run", "-n", "open-mmlab", "/bin/bash", "-c"]

# 4. PyTorch 설치 (성공했던 특정 버전 고정)
RUN pip install torch==1.9.1+cu111 torchvision==0.10.1+cu111 torchaudio==0.9.1 -f https://download.pytorch.org/whl/torch_stable.html

# 5. [핵심] 의존성 지옥 해결을 위한 버전 선점 설치
# Numpy와 Numba를 가장 먼저 고정하여 이후 설치되는 패키지들이 버전을 올리지 못하게 합니다.
RUN pip install numpy==1.19.5 numba==0.48.0 setuptools==59.5.0
RUN pip install pandas==1.4.4 scikit-image==0.19.3 matplotlib==3.5.2
RUN pip install networkx==2.2 tensorboard==2.11.0 protobuf==3.19.6
RUN pip install lyft-dataset-sdk nuscenes-devkit==1.1.9 plyfile==0.7.4 trimesh==2.35.39

# 6. 컴파일러 및 MMLab 핵심 프레임워크 설치
RUN conda install -c omgarcia gcc-6 -y
RUN pip install mmcv-full==1.4.0 -f https://download.openmmlab.com/mmcv/dist/cu111/torch1.9.0/index.html
RUN pip install mmdet==2.14.0 mmsegmentation==0.14.1

# 7. BEVFormer/GenAD 전용 추가 의존성 및 Detectron2
RUN pip install einops fvcore seaborn iopath==0.1.9 timm==0.6.13 typing-extensions==4.5.0
RUN pip install detectron2 -f https://dl.fbaipublicfiles.com/detectron2/wheels/cu111/torch1.9/index.html

# 8. [긴급 수정] Pillow 및 yapf 버전 패치 (Pillow LINEAR 에러 및 yapf verify 에러 방지)
RUN pip install "Pillow<10.0.0" "yapf==0.40.1" --force-reinstall

RUN pip install numpy==1.19.5 numba==0.48.0 --force-reinstall
RUN pip install setuptools==59.5.0

# MLflow
RUN pip install mlflow==2.17.2
RUN pip install "protobuf<4" numpy==1.19.5 numba==0.48.0 --force-reinstall

# 9. 컨테이너 접속 시 자동 설정
RUN conda init bash && echo "conda activate open-mmlab" >> ~/.bashrc

CMD ["/bin/bash"]