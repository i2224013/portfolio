//minimライブラリを追加する必要あり
import ddf.minim.*;
import ddf.minim.effects.*;
import ddf.minim.analysis.*;
FFT fft;
Minim minim; //Minim型変数であるminimの宣言
AudioPlayer player;  //サウンドデータ格納用の変数
LowPassSP lpf;  //ローパスフィルター用の変数
float cutoff;    //削除する周波数のしきい値
int waveH;    //波形の高さ
int currentCircle;  //判定用
int angle;  //角度の初期値
long dragStartTime; // ドラッグを開始した時刻
int resetDuration; // 初期化までの時間 (ミリ秒)
int x; //x座標の初期値
int maxs;//円の最大サイズ
int maxx;//x座標の最大値
int minx;//x座標の最小値
int r, g, b;//色変数
int i, j, k;//繰り返し
int numCircles=400; // 設置する円の配列最大数、400もあれば
int[] mx = new int[numCircles];//マウスx
int[] my = new int[numCircles];//マウスｙ
float[] eSize = new float[numCircles];//サイズに加算
float[] z = new float[numCircles];//サイズ変更、加算減算用
boolean[] isPlaced = new boolean[numCircles];//マウスクリック確認

void setup() {
  size(500, 400);
  //ーーーーーーーー初期化ーーーーーーーーーー
  maxs=x=300;
  maxx=350;
  minx=150;
  resetDuration = 500;
  minim = new Minim(this);
  //バッファは2048
  player = minim.loadFile("wave.wav", 2048);

  lpf = new LowPassSP(5000, player.sampleRate());
  player.addEffect(lpf);    //エフェクトを設定
  fft = new FFT(player.bufferSize(), player.sampleRate());
  waveH = 200;    //波形の高さを初期値200
  player.loop();
}

void draw() {
  //ーーーーーー時間管理ーーーーーーーーーー
  int m = millis();
  m = m % (30*1000);
  //ーーーーー色設定、ランダムーーーーーーーー
  r=int(random(255));
  g=int(random(255));
  b=int(random(255));

  //ーーーーー背景色、時間で変更ーーーーーーー
  if (m<=10*1000) {
    background(0);
  } else if (10*1000<m && m<=20*1000) {
    background(255);
  } else {
    background(r, g, b);
  }
  //ーーーーー丸を書く、時間で色変更ーーーーーーー
  if (m<=10*1000) {
    fill(255);
  } else if (10*1000<m && m<=20*1000) {
    fill(0);
  } else {
    fill(255-r, 255-g, 255-b);//背景と被らないように
  }

  noStroke();
  for (i = 0; i < numCircles; i++) {
    if (isPlaced[i]) {
      float circleSize = eSize[i] + fft.getBand(i) * 10; // 波紋の大きさに変化するサイズを足す
      circleSize = map(circleSize, 0, 1000, 10, maxs);  //サイズに制限を
      ellipse(mx[i], my[i], circleSize, circleSize);

      eSize[i] += z[i];
      if (eSize[i] < 10 || maxs < eSize[i]) {
        z[i] = -z[i];
      }
      if (maxx < mx[i]) {//新たな円が大きい値だったらmaxxを更新
        maxx=mx[i];
      }
      if (minx>mx[i]) {//新たな円が小さい値だったらminxを更新
        minx=mx[i];
      }
      waveH=int(map(my[i], 0, height, 800, 200));//waveHを円のy座標参照の値に
    }
  }
//ーーーーー星と波形を書く、一斉に制御ーーーーーーー
  for (j = 0; j < player.bufferSize() - 1; j++ ) {
//------ーー星を書く、時間で色変更ーーーーーーー
    if (m<=10*1000) {
      fill(50);
    } else if (10*1000<m && m<=20*1000) {
      fill(205);
    } else {
      fill(255-r, 255-g, 255-b);
    }

    pushMatrix(); //現在の座標系を保存
    translate(width/2, height/2);
    rotate(radians(angle));  //座標系を回転
    noStroke();
    if (x>290) {
      stars(int(random(width)), int(random(height)), player.left.get(j)*200 /3);//関数
    }
    popMatrix(); //前の座標系を呼び出す
    
//------ーーー波形を書く、時間で色変更ーーーーーーー
    if (m<=10*1000) {
      stroke(255, 255, b);
    } else if (10*1000<m && m<=20*1000) {
      stroke(0);
    } else {
      stroke(255);
    }
    point(x, 200+player.left.get(j)*waveH);
    x--;
    if (x<minx)x=maxx;//minxの値になったらmaxxから始める、右から左へ

    angle ++;//回転
    if (angle >= 360) angle = 0;
  }
}

void mousePressed() {
  if (currentCircle < numCircles) {
   //クリック時、円を書くのに必要の情報が入る
    mx[currentCircle] = mouseX;
    my[currentCircle] = mouseY;
    eSize[currentCircle] = j/10;
    z[currentCircle] = 2.0; // 大きさの変化速度を設定
    isPlaced[currentCircle] = true;
    currentCircle++;
  }
  dragStartTime = millis();//ドラッグ0.5秒で初期化のタイム
}

void mouseDragged() {
  //毎ドラッグ時値を初期化のようなことをする
  int dragTime = millis() - int(dragStartTime);

  if (dragTime >= resetDuration) {
//ーーーーーーーー初期化ーーーーーーーーーー
    currentCircle = 0;
    for (k = 0; k < numCircles; k++) {
      eSize[k] = 0;
      isPlaced[k] = false;
    }
    maxx=350;
    minx=150;
    waveH = 200;
  }
}
void stars(int x, int y, float r) {//星を書く関数、（頂点のｘ座標、頂点のｘ座標、辺の長さ）
  noStroke();
  //逆三角形、右半分、左半分の3つから構成
  triangle(x, y+r, x+r*1.5, y+r/2.7, x-r*1.5, y+r/2.7);
  triangle(x, y, x, y+r, x-r*1.2, y+r*1.5);
  triangle(x, y, x, y+r, x+r*1.2, y+r*1.5);
}
