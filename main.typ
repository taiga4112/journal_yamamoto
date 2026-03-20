#import "libs/jasnaoe-conf/jasnaoe-conf_lib.typ": jasnaoe-conf
#show: jasnaoe-conf.with()

#import "libs/jasnaoe-conf/direct_bib_lib.typ": bibliography-list, bib-item, use-bib-item-ref
#show: use-bib-item-ref.with(numbering: "1)") // 番号の書式を指定

//----------------------------------------
//以下、申込に必要な最低限の情報です。
//本文には反映されませんが、共著者間でのレビュー時に必要かと思います。
/*
論文タイトル(日本語): モデル予測制御を用いた船体操縦運動に基づく環境場逆推定フレームワークの構築-
Paper Title(English): Development of an Environmental Field Inverse Estimation Framework Based on Ship Maneuvering Dynamics Using Model Predictive Control-
著者1(名前(日本語)、名前(英語), 所属(日本語), 会員種別): 造森船一, Senichi Zomori, 造船大学校, 正会員
著者2(名前(日本語)、名前(英語), 所属(日本語), 会員種別): 海尾学, Manabu Umio, 海洋大学, 学生会員
著者3(名前(日本語)、名前(英語), 所属(日本語), 会員種別): 造田船次郎, Senjiro Zoda, 造船研究所, 学生会員
著者4(名前(日本語)、名前(英語), 所属(日本語), 会員種別): 学会一, Hajime Gakkai, 日本船舶海洋工学会, 学生会員

要旨(日本語300字程度、英語150words程度):
このテンプレートは、2024年秋季講演会以降の日本船舶海洋工学会の講演会論文作成を想定して、Typstで作成しています。
もちろん♡非公式♡のテンプレートですので、ご使用の際は自己責任でお願いします。
*/
//----------------------------------------


= 緒　　言
海事産業では世界の海難事故の約8割が人的要因で発生している他、船員の人員不足、高齢化などの課題を抱えており、これらを解消し得る手段の一つとして自動運航船の実用化に向けた研究開発が数多く行われている #super[@kim_autonomous_2020 @burmeister_autonomous_2014 @li_risk_2023 @he_quantitative_2017 @statheros_autonomous_2008 @felski_ocean-going_2020]。
自動運航船は、従来は船員が行ってきた航路追従や障害物回避などの高度な操船を機械が自律的に実行する必要がある。そのためには高度な操船制御技術に加えて、設計段階から船舶の操縦性能を適切に把握する必要があり、船舶操縦運動モデルの活用が不可欠である。船舶操縦運動モデルは船舶の航路予測や操船制御などに広く用いられており、これまでにも様々なモデルが提案されてきた #super[@yasukawaIntroductionMMGStandard2015 @liu_predictions_2018]。

従来、船舶操縦運動モデルの同定は水槽試験によるPMM（Planar Motion Mechanism）試験やCMT（Captive Model Test）試験、あるいはCFD（Computational Fluid Dynamics）解析を通じて行われてきた #super[@kume_measurements_2006 @ueno_circular_2009 @hao_recurrent_2022 @wang_non-parameterized_2023]。
これらを用いることで船舶の一つの状態における平水中の船舶操縦運動モデルを高精度に同定可能である。しかし実運航では貨物の積載状態やバラスト水の変化、運航海域によって船舶の状態が変化するため、モデル内の流体力学的なパラメータもそれに応じて変動する。これに対し、観測データから船舶の運航状態に合わせたモデルの同定手法があるが、観測データに含まれるノイズなどの不確実性により、同定された船舶操縦運動モデルは不確定なものとなる #super[@mitsuyuki_mmg_2024]。


加えて実海域では、風や波などの外乱影響が支配的となる。従来のMMGモデルなどの船舶操縦運動モデルでは、平水中の操縦運動に対して風や波などの外乱影響に起因して発生する外力を、外力項として線形に加える形で表現することが一般的である #super[@yasukawa_application_2020 @suzuki_numerical_2021 @yasukawa_evaluations_2019 @paroka_prediction_2017]。
これら外力項の推定において、現状では風向・風速や波向・波長などの環境情報を用いて演繹的に算出するアプローチが取られている。しかし海上の波浪ブイや衛生データを用いたとしても、航行中の船舶が受ける局所的かつリアルタイムな環境情報を高い精度で計測することは現状では困難である。また、模型船を用いた水槽試験ベースの外乱モデルには、実海域の複雑な現象を完全に表現しきれないモデル化誤差が内在している。すなわち、不完全なモデルに対して不確かな環境情報を入力せざるを得ないため、結果として船舶操縦運動モデルが出力するシミュレーション結果と観測データが示す波浪中船舶操縦運動との間に無視できない差異が生じている。

一方、近年のGPSやVDR等を用いた航行計測技術の普及により、実船の座標や速度を含む観測データが豊富に取得可能となっている #super[@vu_estimating_2023 @mei_full-scale_2020]。
前述の通り、観測データには観測の不確実性が含まれるが、観測される船舶運動は不確かな環境情報と異なり、船舶の状態や外乱影響が反映された実際の挙動である。
従来の演繹的なアプローチに変わり、平水中の船舶操縦運動モデルとの差異に相当し、かつ船舶の運動を合理的に説明可能な外力を帰納的に算出することができれば、個別の風や波の情報を完全に分離・特定できなくとも、モデル化誤差や観測の不確実性を含んだ上で、現実の波浪中船舶操縦運動を再現可能な外力が得られるはずである。このようなアプローチによる外力データの取得は、実海域での現象を説明可能な船舶操縦運動モデルの構築に寄与すると考えられる。

本研究では、船舶の位置や座標を含む観測データから、平水中の船舶操縦運動モデルとの差異に相当し、かつ船舶の運動を合理的に説明可能な外力を帰納的に算出する「環境場逆推定フレームワーク」を提案する。
環境場とは風速や波高といった気象・海象の物理量ではなく、それらの合計として船体の操縦運動に影響を与える外力モーメント、および水平面内の合力ベクトル（大きさと向き）と定義する。具体的には船舶の位置や速度を含む観測データから推定した合力ベクトルおよび回頭モーメントを船舶の位置座標や時刻と紐づけることで、どの場所でどのような外力が船体に作用しているかを示した空間的な情報として取得する。

本論文における主な貢献を以下に示す。
- 平水中の船舶操縦運動モデルと実海域での観測データとの差異を用いた逆解析により、船体に作用する外力を時系列かつ空間的な情報として推定する環境場逆推定フレームワークを提案した。
- モデルの持つ不確定性を考慮した上で、操船条件を変更した場合と、不確定性の程度を変更したシミュレーションデータ、および波浪中での模型船水槽試験データを用いて提案手法を適用し、その有効性を検証した。

// - 模型船水槽試験データに対して

本論文は以下の内容で構成される。第2章では本研究に関連する研究を述べ、第3章では本研究の提案手法について示す。第4章では、提案手法の有効性をシミュレーションデータと実データの両方に対して検証し結果を議論する。最後に5章には結論を述べる。


= 関連研究
本章では、本研究の提案手法を構成する要素技術に関連する既存研究を紹介し、本研究の位置づけを明確にする。
== 船舶操縦運動モデルのシステム同定
本節では、船舶操縦運動モデルの同定に関する研究を紹介する。前述したように、実海域で取得された観測データを用いて船舶操縦運動モデルを同定する際、データにはノイズなどの不確実性が含まれるため、モデルのパラメータを一意に定数として定めることが困難である。
これに対し、満行らはノイズを含む観測データからのパラメータ推定における課題に対処するため、MCMC法に基づき、MMGモデルにおける操縦流体力微係数を推定する手法を提案している。同手法では、操縦流体力微係数を一つの決定的な値ではなく、不確実性を伴う確率変数として扱っている。そして、観測データに含まれる誤差を考慮するため、以下の観測モデルを独立した正規分布によって定義している。
$
u_italic("obs")(t)~N(u(t), sigma_u) \
v_italic("obs")(t)~N(v(t), sigma_v) \
r_italic("obs")(t)~N(r(t), sigma_r)
$ <eq:observation_model>
ここで、$u_italic("obs")(t), v_italic("obs")(t), r_italic("obs")(t)$ はそれぞれ時刻$t$における速度成分の観測値、$u(t), v(t), r(t)$は真値、$sigma_u, sigma_v, sigma_r$は観測誤差の標準偏差である。
この観測モデルとMCMC法を用いたサンプリングにより、観測の不確実性を内包したまま、操縦流体力微係数のサンプルを複数セットで得ることができる。本研究においても、MCMC法によるアプローチを用いて観測データから得られる不確定な平水中の船舶操縦運動モデルを構築した上で、後述する環境場推定の予測モデルとして活用する。

== 外力推定に関する関連研究
本節では、実観測データと数理モデルの差異に基づき未知の外力を帰納的に導出する既存のアプローチについて整理する。
実海域を航行する船舶が受ける風や波などの環境情報を把握する手段として、波浪ブイや衛生データによる観測があるが、これらは定点観測や広域観測であるため、航行中の船舶が受ける局所的な外乱を正確に取得するのが難しい。一方ですべての船舶に波浪レーダーや高精度な風向風速計などの観測機器を搭載することは、コストや運用面から非現実的である。そこで、観測データと数理モデルの出力との差分から外力を逆推定するアプローチがある。
実観測データとモデルの差分から未知の外力を推定するアプローチとして、外乱オブザーバ(DOB)を用いた研究が多数存在する #super[@gu_disturbance_2022 @menges_environmental_2023]。
DOBは得られた観測状態とモデル出力との差に基づき、未知の外乱成分を時刻ごとに逐次推定する手法である。一方で瞬間的な差分を計算する特性上、観測データに含まれるノイズの影響を受けやすく、推定される外力が振動的になる課題がある。
これに対し、本研究ではモデル予測制御(Model Predictive Control, MPC)を応用する。MPCは、ある時刻において、将来の一定期間にわたる制御入力を最適化する手法である。船舶分野でも目標軌道を追従するように舵角やプロペラ回転数を決定して制御を行う研究が報告されている。本研究ではこの制御入力を船体に作用する未知の外力とする。
MPCを用いることで、観測データとモデル出力との差分を単一の時刻の差分として捉えるのではなく、将来の一定期間にわたる差分として捉えることができるため、観測データに含まれるノイズの影響を緩和しつつ、合理的な外力推定が可能になると考えられる。
= 提案手法
== 概要
#figure(
  placement: bottom, // top, bottom, auto, none
  image("figs/fig_01.svg", width: 100%),
  caption: [Overview of the proposed method.],
) <fig:proposed_method>
本研究の概要を @fig:proposed_method に示す。
本手法は、実海域を航行する船舶の観測データと、不確実性を内包する数理モデルから、対象海域の環境場を帰納的に推定する手法である。まず、船体に取り付けられたVDR(Voyage Data Recorder)などの観測機器から実船の位置・速度などの観測データと舵角・プロペラ回転数といった操縦量データを取得する。
次にこの操縦量データを予測モデルに入力して予測軌道を算出し、実際の観測データから得られる船舶の座標との差に、ペナルティ項を加えたものを評価関数として設定する。ペナルティ項は制御入力である外力項の変化量に重みをかけたものである。予測モデルは平水中の船舶操縦運動モデルを基にし、これに外力項を加えたものを用いる。そして、評価関数の値が最小となるような外力を求め、その値と操縦量データを予測モデルに用いて将来の軌道を算出する。これを繰り返すことで外力の時系列データを得ることができる。
実運航においては積荷状態や運航海域の変化によって船舶の状態が変動するため、本手法では船舶から得られる観測データを用いて同定したモデルを予測モデルに用いる。同定には前章で述べたMCMC法による確率的なシステム同定手法によって得られた複数の操縦流体力微係数セットを活用する。
このベースとなる平水中モデルが有する不確定性を表現するため、前述のパラメータが異なる予測モデルを複数通り用意し、各予測モデルに対してMPCによる軌道追従を実行する。これにより、モデルの不確定性を反映した複数セットの外力時系列データを得る。最後に、得られた外力推定値の分布から統計的な代表値を抽出し、空間固定座標系の位置情報と紐づけることで、対象海域における一つの環境場を構築する。


== 予測モデルの設定
本節ではモデル予測制御で用いる予測モデルの設定、およびその不確定性の考慮について述べる。
前節で述べたように、本手法では操縦流体力微係数の異なる複数の予測モデルを用いる。各予測モデルは、平水中のMMG3自由度モデルを基盤とし、これに外力項を追加した運動方程式を使用する。平水中のMMGモデルでは船体流体力$H$、舵力$R$、プロペラ推力$P$の和で表されるが、予測モデルではこれに加えて外力項$(X_F, Y_F, N_F)$を用いて @eq:predictive_model のように表す。

$
dot(u)&=(X_H+X_R+X_P+X_F+(m+m_y)v r)/(m+m_x)\
dot(v)&=(Y_H+Y_R+Y_F-(m+m_x)u r)/(m+m_y)\
dot(r)&=(N_H+N_R+N_F)/(I_z+J_z)
$ <eq:predictive_model>
ここで、右辺の船体流体力成分$(X_H, Y_H, N_H)$等には操縦流体力微係数が含まれている。本手法では、MCMC法によって同定された不確実性を内包する複数セットの微係数をこれらに代入することで、関数構造は同一でありながらパラメータの異なる複数の予測モデルを構築する。

次に、船体が剛体であると仮定するとモデル予測制御における状態変数$x$は、3自由度の運動を説明するために、船首・船尾の$x,y$座標を用いた合計4個の情報で構成することが可能である。

また、これらの座標は、船体のパラメータと船体固定座標系における速度・角速度$(u, v, r)$及び方位角$psi$を用いて算出可能である。

また、外力項$(X_F, Y_F, N_F)$は、モデル予測制御における制御入力$u$として扱う。

以上より、制御入力$u$と状態変数$x$を用いると、状態変数の時間変化率は @eq:state_variables_derivative の連続時間モデルで表現される。
$
dot(bold(x))(t)=f(bold(x)(t),bold(u)(t))
$ <eq:state_variables_derivative>
// そこで本研究では、前章で述べたMCMC法による確率的なシステム同定手法によって得られたパラメータセットを活用する。

// 予測モデルの設定に同定方法や微係数セットが複数出るという話が入ってしまい、冗長になっている上、予測モデルの説明が後回しになっているため、概要部分を修正し予測モデルの設定を書き直す！
== MPCによる外力項の算出方法
この節ではMPCによる外力項の算出方法について説明する。本研究では、外力項を「制御入力」として、観測から得られた目標軌道と予測モデルから得られる軌道との誤差を最小化するように外力項を算出している。そのために必要な評価関数と最適化問題の設定について述べる。まず、 @eq:state_variables_derivative の連続時間モデルを制御周期$Delta t$ で離散化することで、 @eq:discrete_model に示す離散時間モデルを得ることができる。

$
bold(x)_(t+1)=F(bold(x)_t, bold(u)_t)
$ <eq:discrete_model>

評価関数はある時刻において観測データから得られる目標座標と予測モデルから得られる座標の差の二乗に、制御入力に対するペナルティ項を加えたものである。

$N$を予測ホライゾンとし、評価関数$J$を @eq:mpc_optimization_problem で定義し、これを最小化するように制御入力である外力項を求める。

$
min J(t) =
    sum_(k=1)^(N)(
      bold(e)_(t+k)^T
      bold(Q)
      bold(e)_(t+k))
      + sum_(k=1)^(N-1)(Delta bold(u)_(t+k)^T
      bold(R)
      Delta bold(u)_(t+k) 
    ) \
    s.t space
    cases(
      bold(e)_(t+k)=bold(x)_(t+k)-bold(x)^(r e f)_(t+k),
      bold(x)_(t+1)=F(bold(x)_t, bold(u)_t),
      bold(x)_0=bold(x)_("init"),
      Delta bold(u)_(t+k) = bold(u)_(t+k) - bold(u)_(t+k-1),
    )
$ <eq:mpc_optimization_problem>

ここで、$bold(e)_(t+k)$は時刻$t+k$における状態変数$bold(x)_(t+k)$と観測データから得られる目標座標$bold(x)_(t+k)^(italic("ref"))$の差を表し、$bold(x)_(italic("init"))$は初期状態を表す。また、$Delta bold(u)_(t+k)$は時刻$t+k$における制御入力の変化量を表す。$Q$は状態誤差に対する重み行列、$R$は制御入力の変化量に対する重み行列であり、これらの値を調整することでモデル予測制御の挙動を調整可能である。$Q$の値を大きくすると、目標座標への追従性が向上する一方で、外力の変化量が大きくなり、入力が不安定になる可能性がある。逆に$R$の値を大きくすると、外力の変化量が小さくなり入力が滑らかになる一方で、目標座標への追従性が低下する可能性がある。そして、 @eq:mpc_optimization_problem の最適化問題を解くことで最適入力を導出する。これらを各制御周期で繰り返すことで、時刻ごとに船体に作用する外力項を逐次的に求めることができる。
== 環境場の構築
不確定性を考慮した複数個（$n$個）の予測モデルを用いてMPCを実行することで、各時刻$t$において$n$組の外力推定値のセット$X_(F_t)^(i), Y_(F_t)^(i), N_(F_t)^(i) (i=1,2,...,n)$が得られる。本節ではこれらの分布から各時刻の代表値を決定し、環境場を構築する手順について述べる。

得られた複数の推定値から代表値を決定する方法として、平均値や中央値などの統計的な代表値を用いることが考えられる。しかし、これらの方法は各成分を独立に扱うため、計算された外力成分の組み合わせが実際の現象と乖離する場合があり、各成分間に相関が存在する場合に適切でない。そこで本手法では、外力の3成分をひとつのセットとして扱い、データ全体の中心に位置する実在の推定値の組を代表値として採用する。

具体的には時刻$t$において、$i$番目の無次元化された外力推定値$(tilde(X_(F_t))^(i), tilde(Y_(F_t))^(i), tilde(N_(F_t))^(i))$に対し、他のすべての推定値$j$とのユークリッド距離の総和$D_i(t)$を @eq:distance_sum により計算する。

#set text(size: 8pt)
$
D_i (t)= sum_(j=1)^(n) sqrt((tilde(X_(F_t))^(i)-tilde(X_(F_t))^(j))^2 + (tilde(Y_(F_t))^(i)-tilde(Y_(F_t))^(j))^2 + (tilde(N_(F_t))^(i)-tilde(N_(F_t))^(j))^2)
$ <eq:distance_sum>
#set text(size: 9pt)

この距離の総和$D_i (t)$が最小となる推定値の組$i^*$を選び、その実値 $(X_(F_t)^(i^*), Y_(F_t)^(i^*), N_(F_t)^(i^*))$ を時刻$t$における代表外力として採用する。この方法により、突発的な外れ値の影響を排除しつつ、成分間の物理的な相関を保持した妥当な代表値を決定できる。

最後に、選定された各時刻の代表外力を空間固定座標系の値 $X_F(italic("Earth"))_t$, $Y_F(italic("Earth"))_t$, $N_F(italic("Earth"))_t$ に座標変換する。環境場を構成する合力ベクトルの大きさ$E F_italic("mag")$、向き$E F_italic("dir")$、およびモーメント$E F_italic("mom")$を次のように定義する。

$
E F_italic("mag")_t &= sqrt(X_F(italic("Earth"))_t^2 + Y_F(italic("Earth"))_t^2)\
E F_italic("dir")_t &= tan^(-1)(Y_F(italic("Earth"))_t / X_F(italic("Earth"))_t)\
E F_italic("mom")_t &= N_F(italic("Earth"))_t
$ <eq:environmental_field>

= ケーススタディ
実運航においては、航海ごとに船舶の状態が異なるため、事前の水槽試験などで同定したモデルがそのまま利用できるとは限らないことをこれまでに指摘してきた。そのため航海中の観測データから船舶操縦運動モデルが同定されることを考える。そこで、同一航海データの中に、外乱影響が比較的小さく平水中と仮定できる区間と、風や波の影響を強く受ける外乱区間の両方が存在すると想定する。平水中と仮定できる区間のデータに対してMCMC法を適用し、対象船の操縦流体力微係数セットを導出し、複数の予測モデルを構築する。次に、外乱区間のデータに対して提案手法を適用し、環境場を推定する。
== シミュレーションデータを用いた検証
本節では、外力の真値が既知であるシミュレーションデータを用いて、提案手法の基本性能を検証する。
=== 観測データの作成
本項では平水中と外乱下の観測データの作成方法及び用いた対象船の概要について説明する。観測データの作成にはKCSコンテナ船の実船サイズを用いた。その主要目等については奥田らの論文に記載されている #super[@okuda_validation_2023]。
まず、平水中観測データの作成について述べる。対象船の操縦流体力微係数を用いて平水中のMMG3自由度シミュレーションを実施し、平水中の観測データを作成する。実運航における観測機器の計測誤差を模擬するため、得られた速度成分 $u, v, r$ に対して平均 $0$ の白色ガウスノイズを重畳し、これを観測データとして扱う。
#figure(
  caption: [Standard deviations of white Gaussian noise],
  placement: none, // top, bottom, auto, none
  table(
    columns: 4,
    stroke: (x: none),
    table.header(
      [],
      [$σ_u$[m/s]],
      [$σ_v$[m/s]],
      [$σ_r$[rad/s]],
    ),
    row-gutter: (2.3pt, auto),
    [Noise L1], [$5.0 times 10^(-2)$], [$1.0 times 10^(-1)$], [$2.0 times 10^(-1)$],
    [Noise L2], [$4.0 times 10^(-2)$], [$8.0 times 10^(-2)$], [$1.6 times 10^(-1)$],
    [Noise L3], [$4.0 times 10^(-4)$], [$8.0 times 10^(-4)$], [$1.6 times 10^(-3)$]
  ),
  supplement: "Table",
  kind: table,
) <tb:noise_levels> 
次に、風および波の外力を考慮した外乱下観測データを作成する。風圧力は藤原らによる推定式 #super[@fujiwara_experimental_nodate] 、波浪定常力は安川らによる推定式 #super[@yasukawa_validation_2021] を用いて算出し、これらを真値の外力項として運動方程式の右辺に付加してシミュレーションを行った。本検証における外乱環境を @tb:disturbance_conditions に示す。なお、空間固定座標系で$x$軸正方向を0度とし、時計回りを正の向きとする。
#figure(
  caption: [Environmental disturbance conditions],
  placement: none, // top, bottom, auto, none
  table(
    columns: 2,
    stroke: none,
    align: left,
    table.hline(),
    table.hline(),
    [Wave height: $h_a$], [1.0$[m]$], 
    [Wind speed: $U_(italic("wind"))$], [9.0$["m/s"]$],
    [Wave direction: $chi$], [90$degree$], 
    [Wind direction: $psi_(italic("wind"))$], [0$degree$],
    [Wave length to ship length ratio: $lambda"/"L$], [1.0], 
    table.hline()
  ),
  supplement: "Table",
  kind: table,
) <tb:disturbance_conditions>

=== 提案手法のパラメータ設定
本項では環境場推定に用いるMCMC法およびモデル予測制御のパラメータ設定について述べる。平水中の観測データに対してMCMC法を適用する際に必要な各操縦流体力微係数の事前分布は先行研究 #super[@mitsuyuki_mmg_2024] に倣い一様分布を設定した。サンプリング実施回数は1500回とし、初期の500回を破棄した。そして得られた事後分布からランダムに50個の操縦流体力微係数セットを抽出し、MPCにおける予測モデルの構築に用いた。

MPCの設定値として、予測ホライゾン$N$、制御周期$Delta t$、制御時間$T$を @tab:mpc_params に示す。

#figure(
  placement: none,
  caption: [MPC parameter settings.],
  table(
    columns: 3,
    align: left,
    stroke: (x,y) => if y == 0 {
      (top: 1pt, bottom: 1pt)
    },
    table.header(
      [*Parameter*],
      [*Symbol*],
      [*Value*],
    ),
    row-gutter: (2.2pt, auto),
    [Prediction horizon], [$N$], [$10$ steps], 
    [Control interval], [$Delta t$], [$1.0$ $s$], 
    [Control time], [$T$], [$400$ $s$],
    table.hline()
  ),
  kind: table,
) <tab:mpc_params>

状態変数は、船首・船尾の$x, y$座標を用いた。また、状態変数の誤差と制御入力の変化量に対する重み行列$Q, R$は @eq:mpc_weights のように設定した。

$
  Q &= "diag"(1, 1, 1, 1)\
  R &= "diag"(10^(-5), 10^(-5), 10^(-5))
$ <eq:mpc_weights>

=== 操船条件が推定精度に与える影響
本項では、船体挙動の異なる操船条件が環境場推定の精度に与える影響を検証する。旋回試験の平水中観測データから同定した予測モデル群を用いて、外乱下における操船条件の異なる観測データである20度旋回、Sin操舵、直進の3通りに対して環境場推定を行い、推定精度を比較する。
同定に使用した20度旋回試験の初期条件は、船体初速 $u_0 = 10.4 "m/s", v_0 = 0.0 "m/s", r_0 = 0.0 "rad/s"$, プロペラ回転数 $n_p = 1.75 "rps"$, 舵角 $delta = 20 "deg"$ であり、観測ノイズはNoise L2の条件で作成した。
@fig:observed_data に各観測ノイズでの平水中旋回データを示す。
この観測データに対してMCMC法を適用し、操縦流体力微係数を同定した。

#figure(
  placement: none, // top, bottom, auto, none
  image("figs/fig_02.svg", width: 100%),
  caption: [Observed data in calm water.],
) <fig:observed_data>
#figure(
  placement: none, // top, bottom, auto, none
  image("figs/fig_03.svg", width: 100%),
  caption: [Prior and posterior distributions of hydrodynamic coefficients.],
) <fig:posterior_distributions>
#figure(
  placement: none, // top, bottom, auto, none
  image("figs/fig_04.svg", width: 100%),
  caption: [Calm-water simulation using the identified hydrodynamic derivatives.],
) <fig:calm_water_simulation>
操縦流体力微係数の事後分布を @fig:posterior_distributions に、得られた事後分布から抽出した50セットのモデルを用いて行った平水中シミュレーションの結果を @fig:calm_water_simulation に示す。
パラメータにばらつきはあるものの、いずれのモデルも観測データの軌跡を良好に再現できており、観測誤差による不確実性を内包しつつ物理的な運動を説明可能な予測モデル群が構築されたといえる。

続いて、この20度旋回データから同定された予測モデル群を用い、異なる操船条件の外乱下データに適用した結果を比較する。
各操船条件におけるMPCの軌道追従結果を @fig:trajectory_tracking に、外力推定結果を @fig:external_force_estimation に、構築された環境場を @fig:environmental_field に示す。
@fig:trajectory_tracking より、いずれの操船条件においても実船の目標軌道に良好に追従できている。
外力推定結果を確認すると、目標航路が旋回試験の場合、真値の外力時系列データの形状を捉えた推定ができていることがわかる。。直進試験においては、$Y_F, N_F$ は真値付近に収束している一方で$X_F$ は一定ちには収束しているものの、分布の帯が広がっており、モデルによって推定値に一定のずれが生じていることがわかる。一方で、Sin操舵では推定分布の幅が大きく、真値の形状を捉えられていないことがわかる。
環境場の推定結果において、図中の赤色実線は代表外力、薄赤色は全サンプルの外力分布を表している。
環境場推定結果からも、旋回試験においては真値の方向・大きさと良好に一致している一方で、直進試験やSin操舵試験では推定された環境場の向きが真値から大きく乖離していることがわかる。緑色のベクトルとモーメントはそれぞれ$5 times 10^5N$と$1 times 10^7N m$の大きさを表している。

以上から、本提案手法における環境場の推定精度は、予測モデルの再現性に強く依存すると考えられる。同定に使用した旋回試験データと同一の運動特性を持つ外乱下の旋回試験においては、真値の形状を捉えた推定が可能であった。一方で、非定常な操舵を含むSin操舵や、回頭運動を含まない直進運動に対しては、推定分布の安定性が低下する傾向が見られた。
これは、MCMC法によるモデル同定において、使用した観測データに特化したパラメータ事後分布が形成された結果、学習データに含まれない過渡応答や定常直進状態に対するモデルの予測精度が低下し、そのモデル化誤差がMPCにおける外力推定の不確実性として現れたためと考えられる。
したがって、環境場の推定精度をより広範な操船条件で担保するためには、予測モデルの同定時に、直進・旋回・加減速など多様な運動モードを含む観測データを利用し、モデルの汎化性能を高めておくことが重要であると考えられる。
#figure(
  placement: none, // top, bottom, auto, none
  image("figs/fig_05.svg", width: 100%),
  caption: [Trajectory tracking result.],
) <fig:trajectory_tracking>
#figure(
  placement: none, // top, bottom, auto, none
  image("figs/fig_06.svg", width: 100%),
  caption: [External force estimation result.],
) <fig:external_force_estimation>
#figure(
  placement: none, // top, bottom, auto, none
  image("figs/fig_07.svg", width: 100%),
  caption: [Environmental field.],
) <fig:environmental_field>


=== モデルの不確定性による影響の検証
本項では、予測モデルの同定に用いる平水中データの観測誤差レベルを3段階に変化させることで、モデルの不確定性の程度が環境場推定に与える影響を検証する。

前項の @fig:observed_data および @fig:calm_water_simulation に示した通り、観測ノイズの大きさに応じて同定される操縦流体力微係数の事後分布の広がりは変化する。これら各ノイズレベルで同定された50セットのモデル群を用いて平水中シミュレーションを行った結果を @fig:calm_water_simulation_noise に示す。観測誤差が最も大きいNoise L1から同定したモデル群では、パラメータの大きなばらつきを反映し、軌跡の予測範囲も相対的に広くなっていることがわかる.


次に、これら不確定性の程度が異なる3つの予測モデル群を用い、同一の外乱下データに対して環境場推定を行った。
各ノイズレベルにおけるMPCの軌道追従結果を @fig:trajectory_tracking_noise に、外力推定結果を @fig:external_force_estimation_noise に、環境場推定結果を @fig:environmental_field_noise に示す。
@fig:trajectory_tracking_noise より、いずれの不確定性の程度においても、外力項を制御量とすることで目標軌道に良好に追従できている。
外力推定結果を確認すると、不確定性が小さい場合、推定された外力分布の幅が狭く、真値を良好に捉えている。一方、不確定性の程度が増大するにつれて、推定分布の幅が拡大していることがわかる。

環境場推定結果においても同様に、Noise L1では推定された外力ベクトルの分布が一点に集中しているのに対し、Noise L3では分布の幅が大きくなり、推定の不確実性が増していることが視覚的に確認できる。一方で代表値に着目するとNoise L3であっても真値の方向を概ね捉えていることがわかる。

以上の結果から、平水中データの質が悪化しモデルの不確定性が増大した場合、推定結果のばらつきは大きくなるものの、分布の代表値を用いることで外乱の傾向自体は推定可能であると考えられる。
#figure(
  placement: none, // top, bottom, auto, none
  image("figs/fig_08.svg", width: 100%),
  caption: [Calm-water simulation with different noise levels.],
) <fig:calm_water_simulation_noise>
#figure(
  placement: none, // top, bottom, auto, none
  image("figs/fig_09.svg", width: 100%),
  caption: [Trajectory tracking result with different noise levels.],
) <fig:trajectory_tracking_noise>
#figure(
  placement: none, // top, bottom, auto, none
  image("figs/fig_10.svg", width: 100%),
  caption: [External force estimation result with different noise levels.],
) <fig:external_force_estimation_noise>
#figure(
  placement: none, // top, bottom, auto, none
  image("figs/fig_11.svg", width: 100%),
  caption: [Environmental field result with different noise levels.],
) <fig:environmental_field_noise>

== 自由航走模型試験データを用いた検証
本節では自由航走模型試験で得られた実データを用いて提案手法の有効性を検証する。模型船は内航型コンテナ船の一つであり、舵角-35度の平水中と規則波中の旋回試験データを使用した。波向きは180度、$x$軸正方向である。
=== 提案手法のパラメータ設定
船舶操縦運動モデルの同定に用いるMCMC法のパラメータ設定にあたっては前節と同様に先行研究 #super[@mitsuyuki_mmg_2024] に倣い設定した。MPCの設定値を @tab:mpc_params_model_test に状態変数の誤差と制御入力の変化量に対する重み行列を @eq:mpc_weights_model_test に示す。
$
  Q &= "diag"(1, 1, 1, 1)\
  R &= "diag"(10^(-4), 10^(-4), 10^(-4))
$ <eq:mpc_weights_model_test>
#figure(
  placement: none,
  caption: [MPC parameter settings.],
  table(
    columns: 3,
    align: left,
    stroke: (x,y) => if y == 0 {
      (top: 1pt, bottom: 1pt)
    },
    table.header(
      [*Parameter*],
      [*Symbol*],
      [*Value*],
    ),
    row-gutter: (2.2pt, auto),
    [Prediction horizon], [$N$], [$16$ steps], 
    [Control interval], [$Delta t$], [$0.25$ $s$], 
    [Control time], [$T$], [$50$ $s$],
    table.hline()
  ),
  kind: table,
) <tab:mpc_params_model_test>



=== 推定結果
予測モデル群の構築には、舵角-35度の平水中旋回試験データを用いた。平水中観測データを @fig:observed_data_model に示す。この観測データに対してMCMC法を適用し、操縦流体力微係数を同定した。微係数の事後分布を @fig:posterior_model に、得られた事後分布から抽出した50セットのモデルを用いて行った平水中シミュレーションの結果を @fig:calm_water_simulation_model に示す。
次に、構築した予測モデル群を用い、規則波中の舵角-35度旋回試験データに対して提案手法を適用し、環境場の推定を行った。MPCによる軌道追従結果を @fig:trajectory_model に、構築された環境場の推定結果を @fig:environmental_field_model に示す。
@fig:trajectory_model より、実データにおいても外力項を制御量とすることで、模型船の目標軌道を追従できていることが確認できる。
続いて環境場の推定結果（@fig:environmental_field_model）を確認すると、旋回序盤の船首方向から波を受ける向波の領域では、推定された代表外力ベクトルが実際の波の進行方向である$x$軸正方向と概ね一致している。一般に、水平面内の3自由度モデルでは縦揺れ（ピッチ）等の運動を考慮できないためモデル構造に起因する誤差は存在する。しかし、向波条件では波浪外力が船体運動に対して支配的に作用し、減速などの運動変化が顕著に現れる。そのため、モデル誤差を上回る明確な外乱情報が観測データに含まれており、妥当な環境場が構築できたと考えられる。

一方で、旋回が進行し横波や斜め波を受ける領域に入ると、推定された外力ベクトルが$x$軸正方向から逸脱し、ばらつきが生じる結果となった。これは、パラメータの同定精度ではなく、3自由度モデルの構造的な限界に起因すると推察される。実環境の横波中では、波浪強制力に加えて船体の横傾斜に伴う流体力が強く作用するが、本モデルはロール運動を考慮していない。そのため、ロールによって生じた本来の軌道のズレを、MPCが水平面内の $X, Y, N$ 成分のみで補正しようと最適化計算を行い、波の方向と異なる外力が算出されたと考えられる。

以上の実データ検証より、向波のように外乱の影響度が十分に大きい状況下であれば、本提案手法によって実環境のデータからでも妥当な環境場を推定可能であると考えられる。今後は、横揺れを考慮した4自由度モデルへ拡張するなど、波による運動の変化を正しく表現できるモデル構造が必要であると考えられる。

#figure(
  placement: none, // top, bottom, auto, none
  image("figs/fig_12.svg", width: 100%),
  caption: [Observed data in calm water.],
) <fig:observed_data_model>
#figure(
  placement: none, // top, bottom, auto, none
  image("figs/fig_13.svg", width: 100%),
  caption: [Prior and posterior distributions of hydrodynamic coefficients.],
) <fig:posterior_model>
#figure(
  placement: none, // top, bottom, auto, none
  image("figs/fig_14.svg", width: 100%),
  caption: [Calm-water simulation with identified model parameters.],
) <fig:calm_water_simulation_model>
#figure(
  placement: none, // top, bottom, auto, none
  image("figs/fig_15.svg", width: 100%),
  caption: [Trajectory tracking result.],
) <fig:trajectory_model>
#figure(
  placement: none, // top, bottom, auto, none
  image("figs/fig_16.svg", width: 100%),
  caption: [Environmental field result.],
) <fig:environmental_field_model>




= 結論
本研究では、船舶操縦運動モデルが持つ不確定性を考慮した上で、平水中船舶操縦運動モデルと観測データとの差異を用いた逆解析により、船体に作用する外力を帰納的に推定する環境場逆推定フレームワークを提案した。シミュレーションおよび自由航走模型試験データを用いた検証から、以下の結論を得た。

- 航海中の観測データからモデルを同定する状況を想定し、不確定性を内包したまま推定された外力分布から統計的な中心を抽出することで、妥当な環境場を構築できることを示した。また、ノイズによりモデルの不確定性が増大した場合であっても、代表値を用いることでロバストに外乱傾向を推定できることを確認した。

- 環境場の推定精度は、予測モデルの再現性に依存する。同定に使用した操船条件と同様の運動特性を持つ外乱下のデータに対しては、真値を捉えた推定が可能である一方、その他の操船データに対しては推定値のばらつきが大きくなり、真値を捉えられない傾向があることを確認した。

- 自由航走模型試験への適用により、向波など外乱が支配的な状況では実データでも本手法が有効に機能することを確認した。一方、横波や追い波ではロール運動による推定誤差が生じるため、あらゆる環境下での推定にはモデルの拡張が必要であるという知見を得た。



= 謝　　辞

謝辞が必要なときは、結論の次に書きます。章番号は付けませんが、「謝辞」の表題はセンタリングをして下さい。


// --------------------------------------------------
// 参考文献
// --------------------------------------------------
// 他の.bibファイルを読み込む場合はこの行を使ってください
// ただし、現時点では公式フォーマットで定められている英語日本語の併記には対応できていません
#bibliography("references.bib",
 title: "参　考　文　献",
 style: "libs/jasnaoe-conf/jasnaoe-reference.csl",
 )
// --------------------------------------------------
// // 直接定義する場合はこのコードを編集してください
// #bibliography-list(
//   title: "参　考　文　献", // 参考文献の章のタイトル
// )[
//   #bib-item(<format-en-journal>)[
//     Family names and initials of all authors: Title of the paper, _abbreviated title of the journal (or conference proceedings),_ number of the volume, number of the issue, numbers of the first and last pages, and year of publication.
//   ]
//   #bib-item(<MakiStochastic2023>)[
//     Maki, A., Hoshino, K., Dostal, L. et al.: Stochastic stabilization and destabilization of ship maneuvering motion by multiplicative noise, _Journal of Marine Science and Technology_, 28, 704–718, 2023.
//   ]
//   #bib-item(<OkuboProduction2023>)[
//     Okubo. Y., Mitsuyuki. T.: Study of the practical application of production planning method using shipbuilding process simulation, _Journal of the Japan Society of Naval Architects and Ocean Engineers_, 37, 115-123, 2023 (in Japanese). \
//     大久保友結、満行泰河：船舶建造工程シミュレーションを用いた生産計画立案手法の現場適用に関する研究, _日本船舶海洋工学会論文集_, 37, 115-123, 2023.
//   ]
//   #bib-item(<YamamotoStructure1986>)[
//     Yamamoto, Y., Otsubo, H., Sumi, Y., and Fujino, M.: Ship Structural Mechanics, Seizando-Shoten Publishing Co., Ltd., 1986 (in Japanese). \
//     山本善之、大坪英臣, 角洋一、藤野正隆：船体構造力学、_成山堂書店_、1986。
//   ]
// ]
// --------------------------------------------------