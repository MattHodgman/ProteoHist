# from pandas.io.formats.style_render import DataFrame
#get the features and 
import h5py    
import numpy as np  
import os  
import pandas as pd
import tensorflow as tf
from tensorflow.python.keras.layers import Conv1D, LeakyReLU,MaxPool1D,GlobalAveragePooling1D,Dense,Dropout,AveragePooling1D
from tensorflow.python.keras.models import Sequential
from tensorflow.python.keras.backend import clear_session
from tensorflow.python.keras import layers
import keras

data = h5py.File('/home/fj/Desktop/python_test/bioinfo590/h5_files/C3L-00032-21.h5','r+')    
data = data['features'][:]
df = pd.read_csv("/home/fj/Desktop/python_test/bioinfo590/ucec_proteome_tumor.txt", sep='\t')


number_persample= [data.shape[0]]

label = np.vstack([ df.iloc[ [0],[1,2,3,4] ]  ]*number_persample[0])

list = os.listdir('/home/fj/Desktop/python_test/bioinfo590/h5_files/')


for i in range(len(list)-1):

  temp1 = list[i+1][0:9]
  for j in range(len(df['sample'])):
    if temp1 == df['sample'][j]:

      path = os.path.join('/home/fj/Desktop/python_test/bioinfo590/h5_files/',list[i+1])
      temp = h5py.File(path)
      temp =  temp['features'][:]
      temp2 = np.vstack([ df.iloc[ [j],[1,2,3,4] ]  ]*temp.shape[0])
      label =   np.concatenate((label, temp2), axis=0)
      data = np.concatenate((data, temp), axis=0)
      number_persample.append(temp.shape[0])
      
cut_point = sum(number_persample[0:79]) -1
cut_point1 = sum(number_persample[0:99]) -1
label = label[:,1]

train_gen = data[0:cut_point]
train_label = label[0:cut_point] 



val_gen = data[(cut_point+1):cut_point1]
val_label = label[(cut_point+1):cut_point1]



def build_conv1D_model1():

  # n_timesteps = train_data_reshaped.shape[1] #13
  # n_features  = train_data_reshaped.shape[2] #1 
  model = keras.Sequential(name="model_conv1D")
  model.add(keras.layers.Input(shape=(1024,1)))
  model.add(keras.layers.Conv1D(filters=64, kernel_size=7, activation='relu', name="Conv1D_1"))
  model.add(keras.layers.Dropout(0.5))
  model.add(keras.layers.Conv1D(filters=32, kernel_size=3, activation='relu', name="Conv1D_2"))

  model.add(keras.layers.Conv1D(filters=16, kernel_size=2, activation='relu', name="Conv1D_3"))

  model.add(keras.layers.MaxPooling1D(pool_size=2, name="MaxPooling1D"))
  model.add(keras.layers.Flatten())
  model.add(keras.layers.Dense(32, activation='relu', name="Dense_1"))
  model.add(keras.layers.Dense(1, name="Dense_2"))


  optimizer = tf.keras.optimizers.RMSprop(0.001)

  model.compile(loss='mse',optimizer=optimizer,metrics=['mae'],run_eagerly=True)
  return model

model = build_conv1D_model1()

# cut point is sum(number_persample[0:79]) the first 80 samples are training dataset




history =model.fit(train_gen,train_label,  batch_size=100,epochs =100,validation_data=(val_gen, val_label) )

model.save('1D3.h5')


np.save('1D3.npy',history.history)

results =  model.evaluate(val_gen,val_label,batch_size=100)
print(results)
