import socket
import random

SERVER = 'proj1.3700.network'
PORT = 27993
NUM = 500
BUFFER_SIZE = 4096

ADDR = (SERVER, PORT)

file_path = 'project1-words.txt'
with open(file_path, 'r') as file:
    words = file.readlines()

# Remove any leading/trailing whitespace and newline characters
words = [word.strip() for word in words]

client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
client.connect(ADDR)

msg = '{"type": "hello", "northeastern_username": "tran.ma"}\n'

encoded = msg.encode('utf-8')

client.send(encoded)

receiveID = client.recv(BUFFER_SIZE).decode('utf-8')
print(receiveID)

ID = receiveID.split('"id":"', 1)[1].split('","', 1)[0]

inProgress = True

while (inProgress):
    random_word = random.choice(words)
    print(random_word)
    guess_msg = '{"type": "guess", "id": "' + ID + '", "word": "' + random_word + '"}\n'
    encoded = guess_msg.encode('utf-8')
    client.send(encoded)
    received = client.recv(BUFFER_SIZE).decode('utf-8')

    if ("retry" in received):
        

    if ("bye" in received):
        print("Success: ", received)
        inProgress = False
        break

