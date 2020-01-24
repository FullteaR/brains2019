FROM nvidia/cuda:9.0-cudnn7-devel

LABEL maintainer="frt frt@hongo.wide.ad.jp"

ARG ACCOUNT="frt"
ARG PYTHON_VERSION="3.6.5"
ARG PYTHON_ROOT=/usr/local/bin/python
ARG JUPYTER_PW_HASH="sha1:xxxxxxxxxxxxxxxxxxxxxxxxxxxx"

RUN apt update

RUN apt install -y sudo wget git curl build-essential vim htop
RUN apt install -y libreadline-dev libncursesw5-dev libssl-dev libsqlite3-dev libgdbm-dev libbz2-dev liblzma-dev zlib1g-dev uuid-dev libffi-dev libdb-dev libglib2.0-0 libsm6 libxrender1 libxext6


#ADD USER
RUN groupadd -g 1000 developer && \
    useradd  -g      developer -G sudo -m -s /bin/bash ${ACCOUNT} && \
    echo ${ACCOUNT}:password | chpasswd

#INSTALL PYTHON (use install support tool which is a part of pyenv)
RUN git clone https://github.com/pyenv/pyenv.git ~/.pyenv && cd ~/.pyenv/plugins/python-build && ./install.sh
RUN /usr/local/bin/python-build -v ${PYTHON_VERSION} ${PYTHON_ROOT}
RUN rm -rf ~/.pyenv
ENV PATH $PATH:$PYTHON_ROOT/bin

RUN pip install --upgrade setuptools pip
RUN pip install numpy tensorflow-gpu==2.0.0 keras

RUN pip install seaborn matplotlib tqdm jupyter opencv-python pandas xlrd xgboost sklearn Pillow 
RUN apt install -y libxrender1 libsm6

RUN mkdir /root/.jupyter && touch /root/.jupyter/jupyter_notebook_config.py
RUN echo "c.NotebookApp.ip = '0.0.0.0'" >> /root/.jupyter/jupyter_notebook_config.py
RUN echo c.NotebookApp.open_browser = False >> /root/.jupyter/jupyter_notebook_config.py
RUN echo c.NotebookApp.password = \'${JUPYTER_PW_HASH}\' >> /root/.jupyter/jupyter_notebook_config.py

CMD jupyter notebook --allow-root 


