## Installation

```bash

  # install dependencies using pip 
  pip install -r ./requirement.txt
```

- **Pretrained model** provided in ./model folder in this repo 

- **Download yolov5 (old version) from this link:** [yolov5 - google drive](https://drive.google.com/file/d/1g1u7M4NmWDsMGOppHocgBKjbwtDA-uIu/view?usp=sharing)

- Copy yolov5 folder to project folder

## Run

```bash
  # run inference on webcam (15-20fps if there is 1 license plate in scene)
  uvicorn main:app --host 0.0.0.0 --port 8000 --reload

```