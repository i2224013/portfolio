print("赤のカラーコードを入力")
r= input()
print("緑のカラーコードを入力")
g= input()
print("青のカラーコードを入力")
b=input()

r_num = int(r,16)
g_num = int(g,16)
b_num = int(b,16)

print("赤:",r_num,r_num/255)
print("緑:",g_num,g_num/255)
print("青:",b_num,b_num/255)

