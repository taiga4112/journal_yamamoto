#import "libs/jasnaoe-conf/jasnaoe-conf_lib.typ": jasnaoe-conf
#show: jasnaoe-conf.with()

#import "libs/jasnaoe-conf/direct_bib_lib.typ": bibliography-list, bib-item, use-bib-item-ref
#show: use-bib-item-ref.with(numbering: "1)") // 番号の書式を指定

//----------------------------------------
/*
Paper Title: Environmental Field Reconstruction for Ship Maneuvering Using Uncertainty-Aware Inverse Estimation with Model Predictive Control
著者1(名前(日本語)、名前(英語), 所属(日本語), 会員種別): 造森船一, Senichi Zomori, 造船大学校, 正会員
著者2(名前(日本語)、名前(英語), 所属(日本語), 会員種別): 海尾学, Manabu Umio, 海洋大学, 学生会員
著者3(名前(日本語)、名前(英語), 所属(日本語), 会員種別): 造田船次郎, Senjiro Zoda, 造船研究所, 学生会員
著者4(名前(日本語)、名前(英語), 所属(日本語), 会員種別): 学会一, Hajime Gakkai, 日本船舶海洋工学会, 学生会員

Abstract:
This study proposes an environmental field reconstruction framework for ship maneuvering based on uncertainty-aware inverse estimation using model predictive control (MPC). Unlike conventional approaches that treat wind and wave effects as disturbances, the proposed method explicitly reconstructs them as spatially distributed external force fields from observed ship motion.
Hydrodynamic derivatives are first identified from calm-water data using a Markov Chain Monte Carlo (MCMC) approach, yielding a posterior distribution that captures model uncertainty. Multiple maneuvering models are then generated from this distribution. External forces are estimated by formulating MPC with these forces treated as control inputs, minimizing the discrepancy between measured and predicted trajectories over a finite horizon.
To account for model uncertainty, force estimation is performed across multiple models, and a representative force is extracted from the resulting distribution. The environmental field is then reconstructed by mapping these estimated forces to vessel positions.
The proposed method is validated using both simulation data with known ground truth and free-running model test data under wave conditions. The results demonstrate that the method can reconstruct environmental fields when predictive models are sufficiently accurate, and that representative estimation enables robust inference even under increased uncertainty. However, estimation accuracy depends on model generalization, and structural limitations such as neglecting roll motion lead to degraded performance under certain wave conditions.
The proposed framework provides a data-driven approach for environmental effect estimation in ship maneuvering and highlights the importance of model structure and uncertainty handling.
*/
//----------------------------------------


= 緒　　言

海事産業では世界の海難事故の約8割が人的要因で発生している他、船員の人員不足、高齢化などの課題を抱えており、これらを解消し得る手段の一つとして自動運航船の実用化に向けた研究開発が数多く行われている #super[@kim_autonomous_2020 @burmeister_autonomous_2014 @li_risk_2023 @he_quantitative_2017 @statheros_autonomous_2008 @felski_ocean-going_2020]。
自動運航船は、従来は船員が行ってきた航路追従や障害物回避などの高度な操船を機械が自律的に実行する必要がある。
そのためには高度な操船制御技術に加えて、設計段階から船舶の操縦性能を適切に把握する必要があり、船舶操縦運動モデルの活用が不可欠である。
船舶操縦運動モデルは船舶の航路予測や操船制御などに広く用いられており、これまでにも様々なモデルが提案されてきた #super[@yasukawaIntroductionMMGStandard2015 @liu_predictions_2018]。
しかし、これらのモデルは主として平水中の挙動を対象としており、実海域での外乱影響を十分に反映するものではない。

従来、船舶操縦運動モデルの同定は水槽試験によるPMM（Planar Motion Mechanism）試験やCMT（Captive Model Test）試験、あるいはCFD（Computational Fluid Dynamics）解析を通じて行われてきた #super[@kume_measurements_2006 @ueno_circular_2009 @hao_recurrent_2022 @wang_non-parameterized_2023]。
これらを用いることで船舶の一つの状態における平水中の船舶操縦運動モデルを高精度に同定可能である。
しかし実運航では貨物の積載状態やバラスト水の変化、運航海域によって船舶の状態が変化するため、モデル内の流体力学的なパラメータもそれに応じて変動する。
これに対し、観測データから船舶の運航状態に合わせたモデルの同定手法があるが、観測データに含まれるノイズなどの不確実性により、同定された船舶操縦運動モデルは不確定なものとなる #super[@mitsuyuki_mmg_2024]。

加えて実海域では、風や波などの外乱影響が支配的となる。
これらの外力は一般に外乱として扱われるが、その影響は単なるノイズとは異なり、時間的および空間的な構造を有する現象である。
従来のMMGモデルなどの船舶操縦運動モデルでは、平水中の操縦運動に対して風や波などの外乱影響に起因して発生する外力を、外力項として線形に加える形で表現することが一般的である #super[@yasukawa_application_2020 @suzuki_numerical_2021 @yasukawa_evaluations_2019 @paroka_prediction_2017]。
これら外力項の推定においては、風向・風速や波向・波長などの環境情報を用いて演繹的に算出するアプローチが主に用いられている。
しかし、海上の波浪ブイや衛星データを用いたとしても、航行中の船舶が受ける局所的かつリアルタイムな環境情報を高い精度で取得することは現状では困難である。
また、模型船を用いた水槽試験に基づく外乱モデルには、実海域の複雑な現象を完全に表現しきれないモデル化誤差が内在している。
すなわち、不完全なモデルに対して不確かな環境情報を入力せざるを得ないため、結果として船舶操縦運動モデルが出力するシミュレーション結果と観測データが示す波浪中船舶操縦運動との間に無視できない差異が生じている。
この差異は単なるモデル誤差ではなく、外力の表現および推定の不確かさに起因する可能性がある。

一方、近年のGPSやVDR等を用いた航行計測技術の普及により、実船の座標や速度を含む観測データが豊富に取得可能となっている #super[@vu_estimating_2023 @mei_full-scale_2020]。
前述の通り、観測データには観測の不確実性が含まれるが、観測される船舶運動は不確かな環境情報とは異なり、船舶の状態および外乱影響が反映された実際の挙動である。
このような観測データに基づき、平水中の船舶操縦運動モデルとの差異に相当し、かつ船舶運動を合理的に説明可能な外力を帰納的に推定することができれば、個別の風や波の情報を完全に分離・特定できなくとも、モデル化誤差や観測の不確実性を内包した形で、実海域における船舶操縦運動を再現可能な外力を導出することが可能となる。
このとき得られる外力は単なる時系列的な外乱ではなく、船体運動に影響を与える外力の分布として解釈可能であり、環境場としての再構成に繋がる。
このようなアプローチによる外力データの取得は、実海域での現象を説明可能な船舶操縦運動モデルの構築に寄与すると考えられる。

本研究では、船舶の位置や速度を含む観測データに基づき、平水中の船舶操縦運動モデルとの差異を説明する外力を逆問題として推定する「環境場逆推定フレームワーク」を提案する。
本手法では未知の外力を制御入力として扱い、観測データとモデル出力との整合性を有限時間ホライゾンにわたって最小化する最適化問題として定式化することで、時間的整合性を有する外力系列を導出する。
環境場とは風速や波高といった気象・海象の物理量そのものではなく、それらの合成結果として船体の操縦運動に影響を与える外力モーメント、および水平面内の合力ベクトル（大きさと向き）として定義する。
具体的には、船舶の位置や速度を含む観測データから推定された合力ベクトルおよび回頭モーメントを船舶の位置座標および時刻と紐づけることで、船体に作用する外力を空間的に分布した情報として再構成する。

本論文における主な貢献を以下に示す。
- 平水中の船舶操縦運動モデルと実海域での観測データとの差異を逆問題として定式化し、船体に作用する外力を時間的整合性を持つ時系列および空間情報として推定する環境場逆推定フレームワークを提案した。
- モデルの不確定性を考慮したシミュレーションデータ（操船条件および不確定性の変化を含む）および波浪中の模型船水槽試験データに対して提案手法を適用し、その有効性を検証した。


= 関連研究

== 船舶操縦運動モデルのシステム同定

本節では、船舶操縦運動モデルの同定に関する研究を紹介する。
前述したように、実海域で取得された観測データを用いて船舶操縦運動モデルを同定する際、データにはノイズなどの不確実性が含まれるため、モデルのパラメータを一意に定数として定めることが困難である。

これに対し、満行らはノイズを含む観測データからのパラメータ推定における課題に対処するため、MCMC法に基づき、MMGモデルにおける操縦流体力微係数を推定する手法を提案している。
同手法では、操縦流体力微係数を一つの決定的な値ではなく、不確実性を伴う確率変数として扱う。

そして、観測データに含まれる誤差を考慮するため、以下の観測モデルを独立した正規分布によって定義している。

$
u_italic("obs")(t)~N(u(t), sigma_u) \
v_italic("obs")(t)~N(v(t), sigma_v) \
r_italic("obs")(t)~N(r(t), sigma_r)
$ <eq:observation_model>

ここで、$u_italic("obs")(t), v_italic("obs")(t), r_italic("obs")(t)$ はそれぞれ時刻$t$における速度成分の観測値、$u(t), v(t), r(t)$は真値、$sigma_u, sigma_v, sigma_r$は観測誤差の標準偏差である。

この観測モデルとMCMC法を用いたサンプリングにより、観測の不確実性を内包したまま、操縦流体力微係数のサンプルを複数セットで得ることができる。
本研究においても、MCMC法によるアプローチを用いて観測データから得られる不確定な平水中の船舶操縦運動モデルを構築し、後述する外力推定における予測モデルとして活用する。

== 外力推定に関する関連研究

本節では、実観測データと数理モデルの差異に基づき未知の外力を推定する既存手法を整理し、本研究の位置づけを明確にする。

実海域を航行する船舶が受ける風や波などの環境情報を把握する手段として、波浪ブイや衛星データによる観測があるが、これらは定点観測や広域観測であるため、航行中の船舶が受ける局所的な外乱を正確に取得することは難しい。
また、すべての船舶に高精度な観測機器を搭載することはコストや運用面から現実的ではない。

このような背景から、観測データと数理モデルの出力との差分に基づき外力を推定するアプローチが提案されている。
代表的な手法として、外乱オブザーバ（Disturbance Observer, DOB）を用いた研究が多数存在する #super[@gu_disturbance_2022 @menges_environmental_2023]。
DOBは観測状態とモデル出力との差に基づき未知の外乱成分を逐次推定する手法であり、リアルタイム性に優れる。

しかし、DOBに代表される手法では、外力は各時刻における残差に基づいて独立に推定されるため、観測ノイズの影響を受けやすく、推定結果が振動的となる傾向がある。
また、推定される外力は時系列信号として扱われることが多く、その空間的構造や物理的解釈については十分に考慮されていない。

また、状態推定の枠組みとして、過去の一定期間の観測データを用いて状態や外乱を推定するMoving Horizon Estimation（MHE）に基づく手法も提案されている。
MHEは有限時間ホライゾンにわたる最適化問題として定式化されるため、観測ノイズに対してロバストであり、時間的整合性を考慮した推定が可能である。
しかし、MHEは主として状態推定を目的とした枠組みであり、推定される外力は観測データを説明するための補助変数として扱われることが多い。
一方で、本研究で対象とする風や波に起因する外力は、単なる微小な外乱として扱うには不十分であり、船舶の操縦運動に対して支配的な影響を及ぼす場合がある。
このような外力は時間的・空間的な構造を持ち、船舶運動に対して支配的な影響を及ぼすため、単に状態推定の一部として扱うのではなく、主たる推定対象として明示的に取り扱う必要がある。

そのため本研究では、外力を制御入力として明示的に扱い、モデル予測制御（Model Predictive Control, MPC）の枠組みにより外力を直接推定するアプローチを採用する。
すなわち、観測データとモデル出力との差を有限時間ホライゾンにわたって最小化する最適化問題として外力を推定する。
この定式化により、各時刻の差分に基づく逐次推定とは異なり、時間的整合性を有する外力系列を導出することが可能となる。
さらに、本研究の目的は外力の時系列推定に留まらず、推定された外力を船舶の位置情報と結びつけることで、空間的に分布した環境場として再構成する点にある。
したがって、本研究は従来の外乱オブザーバや状態推定に基づく外力推定とは異なり、外力推定を環境場再構成のための逆問題として再定式化する点に特徴がある。


= 提案手法

== 概要

#figure(
  placement: bottom,
  image("figs/fig_01.svg", width: 100%),
  caption: [Overview of the proposed method.],
) <fig:proposed_method>

本研究の概要を @fig:proposed_method に示す。
本手法は、実海域を航行する船舶の観測データと、不確実性を内包する数理モデルに基づき、対象海域における環境場を逆問題として推定する手法である。

まず、船体に搭載されたVDR（Voyage Data Recorder）などの観測機器から、実船の位置・速度などの観測データと、舵角・プロペラ回転数といった操縦量データを取得する。

次に、これらの操縦量を予測モデルに入力し、将来の船舶運動を予測する。
本手法では、観測データと予測結果との差を評価関数として定式化し、これを有限時間ホライゾンにわたって最小化する最適化問題として外力推定を行う。
評価関数は、観測データから得られる船舶の状態と予測モデルの出力との差に加え、制御入力である外力の時間変化に対するペナルティ項を含む。
このペナルティ項により、非物理的な急激な変動を抑制し、時間的に整合した外力系列の推定を可能とする。

予測モデルには、平水中の船舶操縦運動モデルに外力項を付加したものを用いる。
そして、評価関数を最小化する外力を求め、その結果を用いて船舶の運動を逐次更新することで、外力の時系列データを導出する。

実運航においては、積荷状態や運航海域の変化により船舶の動特性が変動するため、本手法では観測データに基づき同定されたモデルを予測モデルとして用いる。
同定には前章で述べたMCMC法による確率的システム同定を用い、複数の操縦流体力微係数セットを取得する。

このモデル不確定性を考慮するため、異なるパラメータを持つ複数の予測モデルを用意し、それぞれに対してMPCによる外力推定を実行する。
これにより、モデルの不確定性を反映した複数の外力時系列データを得ることができる。

最後に、得られた外力推定値の分布から統計的な代表値を抽出し、船舶の位置情報と紐づけることで、対象海域における外力の空間分布、すなわち環境場として再構成する。

== 予測モデルの設定

本節では、モデル予測制御において用いる予測モデルの構築方法およびその不確定性の考慮について述べる。

前節で述べたように、本手法では操縦流体力微係数の異なる複数の予測モデルを用いる。
各予測モデルは、平水中のMMG3自由度モデルを基盤とし、これに外力項を付加した運動方程式により表現される。

平水中のMMGモデルでは、船体流体力$H$、舵力$R$、プロペラ推力$P$の和により運動が記述されるが、本研究ではこれに外力項$(X_F, Y_F, N_F)$を加え、以下のように表す。

$
dot(u)&=(X_H+X_R+X_P+X_F+(m+m_y)v r)/(m+m_x)\
dot(v)&=(Y_H+Y_R+Y_F-(m+m_x)u r)/(m+m_y)\
dot(r)&=(N_H+N_R+N_F)/(I_z+J_z)
$ <eq:predictive_model>

ここで、右辺の船体流体力成分$(X_H, Y_H, N_H)$等には操縦流体力微係数が含まれる。
本手法では、MCMC法により同定された複数の微係数セットをこれらに代入することで、同一の関数構造を持ちながらパラメータの異なる複数の予測モデルを構築する。

次に、モデル予測制御における状態変数を定義する。
本研究では船体を剛体と仮定するため、船体の平面運動は3自由度（前後・左右の並進運動および回転運動）によって記述される。

このとき、船体の位置および姿勢は平面上の幾何情報として表現可能であり、状態変数は$x, y$座標に基づく有限個の変数で構成することができる。
状態変数の具体的な取り方は一意ではないが、本研究では一例として、船首および船尾の位置座標を用いた4次元の状態ベクトル
$
bold(x) = [x_b, y_b, x_s, y_s]^T
$
を採用する。
このような表現により、船体の並進および回転運動を幾何的に記述することが可能となる。
なお、状態変数の定義は本手法の本質には依存せず、他の座標系や状態表現を用いることも可能である。

これらの座標は、船体固定座標系における速度・角速度$(u, v, r)$および方位角$psi$と船体幾何情報に基づいて算出される。

また、外力項$(X_F, Y_F, N_F)$は、モデル予測制御における制御入力ベクトル
$
bold(u) = [X_F, Y_F, N_F]^T
$
として扱う。

以上より、状態変数の時間発展は、制御入力を含む非線形システムとして以下の連続時間モデルで表される。

$
dot(bold(x))(t)=f(bold(x)(t),bold(u)(t))
$ <eq:state_variables_derivative>

== MPCによる外力項の算出方法

本節では、モデル予測制御（MPC）に基づく外力項の推定方法について述べる。
本研究では、外力項を制御入力として扱い、観測データと予測モデルの出力との整合性を満たすように外力を推定する。

このときの目的は、目標軌道への追従ではなく、観測データとして与えられる船舶運動を最もよく説明する外力系列を導出することであり、本問題は逆問題として定式化される。

まず、 @eq:state_variables_derivative の連続時間モデルを制御周期$Delta t$で離散化することで、以下の離散時間モデルを得る。

$
bold(x)_(t+1)=F(bold(x)_t, bold(u)_t)
$ <eq:discrete_model>

次に、評価関数を定義する。
本研究では、観測データから得られる状態と予測モデルの状態との差に基づく誤差項と、制御入力である外力の時間変化に対するペナルティ項を組み合わせた評価関数を用いる。

予測ホライゾンを$N$とし、評価関数$J$を以下の最適化問題として定式化する。

$
min J(t) =
    sum_(k=1)^(N)(
      bold(e)_(t+k)^T
      bold(Q)
      bold(e)_(t+k))
      + sum_(k=1)^(N-1)(
      Delta bold(u)_(t+k)^T
      bold(R)
      Delta bold(u)_(t+k)
    ) \
    s.t space
    cases(
      bold(e)_(t+k)=bold(x)_(t+k)-bold(x)_(t+k)^(italic("ref")),
      bold(x)_(t+1)=F(bold(x)_t, bold(u)_t),
      bold(x)_0=bold(x)_("init"),
      Delta bold(u)_(t+k) = bold(u)_(t+k) - bold(u)_(t+k-1),
    )
$ <eq:mpc_optimization_problem>

ここで、$bold(e)_(t+k)$は時刻$t+k$における状態誤差、$bold(x)_(t+k)^(italic("ref"))$は観測データから得られる参照状態、$bold(x)_("init")$は初期状態を表す。
また、$Delta bold(u)_(t+k)$は制御入力の時間変化量を表す。

重み行列$bold(Q)$および$bold(R)$は、それぞれ状態誤差および入力変化に対する重みを表し、これらを調整することで推定される外力系列の性質を制御することができる。
$bold(Q)$を大きくすると観測データへの適合度が向上する一方で、外力の変動が大きくなる可能性がある。
一方、$bold(R)$を大きくすると外力の時間変化が抑制され、より滑らかな外力系列が得られる。

以上の最適化問題を各時刻で逐次的に解くことにより、時間的整合性を有する外力系列を推定することができる。

== 環境場の構築

不確定性を考慮した$n$個の予測モデルに対してMPCを適用することで、各時刻$t$において$n$組の外力推定値
$
(X_(F_t)^(i), Y_(F_t)^(i), N_(F_t)^(i)), quad i=1,2,...,n
$
が得られる。
本節では、これらの分布から各時刻における代表外力を決定し、環境場を構築する方法について述べる。

複数の推定値から代表値を決定する方法としては、平均値や中央値などの統計量を用いることが一般的である。
しかし、これらの方法は各成分を独立に処理するため、外力成分間に存在する相関構造が失われ、物理的に不整合な組み合わせが生成される可能性がある。

そこで本研究では、外力の3成分を一つのベクトルとして扱い、分布の中心に最も近い「実在する推定値」を代表値として選択する手法を採用する。
これは、多次元空間におけるロバストな代表値推定と解釈できる。

具体的には、時刻$t$において$i$番目の無次元化された外力ベクトル
$
(tilde(X_(F_t))^(i), tilde(Y_(F_t))^(i), tilde(N_(F_t))^(i))
$
に対し、他のすべての推定値$j$とのユークリッド距離の総和$D_i(t)$を以下のように定義する。

#set text(size: 7.5pt)
$
D_i (t)= sum_(j=1)^(n) sqrt(
(tilde(X_(F_t))^(i)-tilde(X_(F_t))^(j))^2 +
(tilde(Y_(F_t))^(i)-tilde(Y_(F_t))^(j))^2 +
(tilde(N_(F_t))^(i)-tilde(N_(F_t))^(j))^2
)
$ <eq:distance_sum>
#set text(size: 9pt)

この距離総和$D_i(t)$が最小となるインデックス$i^*$を選択し、その実値
$
(X_(F_t)^(i^*), Y_(F_t)^(i^*), N_(F_t)^(i^*))
$
を時刻$t$における代表外力とする。

この手法により、外れ値の影響を抑制しつつ、外力成分間の相関構造を保持した物理的に整合した代表値を得ることができる。

最後に、各時刻における代表外力を空間固定座標系へ変換する。
これにより、船体に作用する外力を位置情報と結びつけた環境場として表現することが可能となる。

環境場を構成する合力ベクトルの大きさ$E F_italic("mag")$、方向$E F_italic("dir")$、およびモーメント$E F_italic("mom")$を以下のように定義する。

$
E F_italic("mag")_t &= sqrt(X_F(italic("Earth"))_t^2 + Y_F(italic("Earth"))_t^2)\
E F_italic("dir")_t &= tan^(-1)(Y_F(italic("Earth"))_t / X_F(italic("Earth"))_t)\
E F_italic("mom")_t &= N_F(italic("Earth"))_t
$ <eq:environmental_field>

以上により、本手法は観測データから推定された外力系列を、船舶の航行軌跡に沿った空間分布として再構成する。
すなわち、各時刻における$(E F_italic("mag")_t, E F_italic("dir")_t, E F_italic("mom")_t)$は、当該位置において船体に作用した環境影響を表す量であり、これらの集合として対象海域の環境場が定義される。

このように、本研究では外力推定を単なる時系列推定に留めず、空間的に分布した環境情報の再構成問題として扱う点に特徴がある。


= ケーススタディ

本章では、提案手法の有効性を検証するため、シミュレーションデータおよび実験データを用いたケーススタディを実施する。

実運航においては、航海ごとに積荷状態や環境条件が変化するため、事前の水槽試験等で同定されたモデルをそのまま適用することは必ずしも適切ではない。
そのため本研究では、航海中に取得された観測データに基づいてモデル同定および外力推定を行う枠組みを想定する。

具体的には、同一航海データ中に、外乱の影響が比較的小さく平水中とみなせる区間と、風や波の影響を強く受ける外乱区間の両方が存在すると仮定する。
まず、平水中区間のデータに対してMCMC法を適用し、操縦流体力微係数の分布を推定することで複数の予測モデルを構築する。
次に、外乱区間のデータに対して提案手法を適用し、外力の時系列および環境場を推定する。

このように、本ケーススタディでは、実運航を模擬した条件下において、「モデル同定」と「外力推定」を分離して実施することで、提案手法の適用可能性を検証する。

== シミュレーションデータを用いた検証

本節では、外力の真値が既知であるシミュレーションデータを用いて、提案手法の基本性能および推定精度を定量的に検証する。
ここでいう真値とは、数理モデルにより明示的に与えた外力項を指す。

=== 観測データの作成

本項では、提案手法の検証に用いる観測データの生成方法について説明する。
本検証では、平水中区間と外乱区間の双方を含むデータセットを人工的に生成することで、実運航環境を模擬する。
観測データの作成にはKCSコンテナ船の実船サイズを用いた。
その主要目等については奥田らの論文に記載されている #super[@okuda_validation_2023]。

まず、平水中観測データの作成について述べる。
対象船の操縦流体力微係数を用いて平水中のMMG3自由度シミュレーションを実施し、平水中の観測データを作成する。
実運航における観測機器の計測誤差を模擬するため、得られた速度成分 $u, v, r$ に対して平均 $0$ の白色ガウスノイズを重畳し、これを観測データとして扱う。

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

次に、風および波の外力を考慮した外乱下観測データを作成する。
風圧力は藤原らによる推定式 #super[@fujiwara_experimental_nodate] 、波浪定常力は安川らによる推定式 #super[@yasukawa_validation_2021] を用いて算出し、これらを真値の外力項として運動方程式の右辺に付加してシミュレーションを行った。
本検証における外乱環境を @tb:disturbance_conditions に示す。
なお、空間固定座標系で$x$軸正方向を0度とし、時計回りを正の向きとする。

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

このように生成した外乱区間のデータに対して提案手法を適用し、外力の推定精度および環境場の再構成能力を評価する。

=== 提案手法のパラメータ設定

本項では、環境場推定に用いるMCMC法およびモデル予測制御（MPC）のパラメータ設定について述べる。

まず、平水中の観測データに対してMCMC法を適用する際に必要な各操縦流体力微係数の事前分布は、特定の値に偏らないよう先行研究 #super[@mitsuyuki_mmg_2024] に倣い一様分布を設定した。
サンプリング回数は1500回とし、収束前のサンプルを除去するため初期の500回をバーンインとして破棄した。
得られた事後分布からランダムに50組の操縦流体力微係数セットを抽出し、モデル不確定性を反映した複数の予測モデルの構築に用いた。

次に、MPCの設定について述べる。
予測ホライゾン$N$、制御周期$Delta t$、制御時間$T$を @tab:mpc_params に示す。
予測ホライゾンは、計算負荷と時間的整合性のトレードオフを考慮して設定している。

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

状態変数は、船体を剛体と仮定し、船首および船尾の$x, y$座標を用いた。
また、状態誤差および制御入力の変化量に対する重み行列$Q, R$は以下のように設定した。

$
  Q &= "diag"(1, 1, 1, 1)\
  R &= "diag"(10^(-5), 10^(-5), 10^(-5))
$ <eq:mpc_weights>

ここで、$Q$は観測データへの適合度を制御し、$R$は外力の時間変化の滑らかさを制御する。
本研究では、観測データとの整合性を優先しつつ、不自然に振動する外力推定を抑制するためにこれらの値を設定した。

=== 操船条件が推定精度に与える影響

本項では、船体挙動の異なる操船条件が環境場推定の精度に与える影響を検証する。
特に、モデル同定に用いた運動と異なる操船条件に対して提案手法を適用した場合の推定性能の変化に着目する。

旋回試験の平水中観測データから同定した予測モデル群を用いて、外乱下における操船条件の異なる観測データである20度旋回、Sin操舵、直進の3通りに対して環境場推定を行い、推定精度を比較する。

同定に使用した20度旋回試験の初期条件は、船体初速 $u_0 = 10.4 "m/s", v_0 = 0.0 "m/s", r_0 = 0.0 "rad/s"$、プロペラ回転数 $n_p = 1.75 "rps"$、舵角 $delta = 20 "deg"$ であり、観測ノイズはNoise L2の条件で作成した。
@fig:observed_data に平水中旋回データを示す。
この観測データに対してMCMC法を適用し、操縦流体力微係数を同定した。

#figure(
  placement: none,
  image("figs/fig_02.svg", width: 100%),
  caption: [Observed data in calm water.],
) <fig:observed_data>

#figure(
  placement: none,
  image("figs/fig_03.svg", width: 100%),
  caption: [Prior and posterior distributions of hydrodynamic coefficients.],
) <fig:posterior_distributions>

#figure(
  placement: none,
  image("figs/fig_04.svg", width: 100%),
  caption: [Calm-water simulation using the identified hydrodynamic derivatives.],
) <fig:calm_water_simulation>

操縦流体力微係数の事後分布を @fig:posterior_distributions に、得られた事後分布から抽出した50セットのモデルを用いた平水中シミュレーション結果を @fig:calm_water_simulation に示す。
いずれのモデルも観測データの軌跡を良好に再現できており、観測誤差による不確実性を内包しつつ物理的に整合した予測モデル群が構築されていることが確認できる。

次に、この予測モデル群を用いて異なる操船条件の外乱下データに対して提案手法を適用した結果を示す。
各操船条件における軌道再現結果を @fig:trajectory_tracking に、外力推定結果を @fig:external_force_estimation に、構築された環境場を @fig:environmental_field に示す。

#figure(
  placement: none,
  image("figs/fig_05.svg", width: 100%),
  caption: [Trajectory tracking result.],
) <fig:trajectory_tracking>

#figure(
  placement: none,
  image("figs/fig_06.svg", width: 100%),
  caption: [External force estimation result.],
) <fig:external_force_estimation>

#figure(
  placement: none,
  image("figs/fig_07.svg", width: 100%),
  caption: [Environmental field.],
) <fig:environmental_field>

@fig:trajectory_tracking より、いずれの操船条件においても観測データに対する軌道再現は良好である。
しかしながら、外力推定結果および環境場の再構成結果には操船条件による顕著な差異が見られる。

旋回試験においては、外力時系列の形状および環境場の方向・大きさともに真値と良好に一致している。
一方、直進試験では $Y_F, N_F$ は真値付近に収束するものの、$X_F$ に関しては推定分布のばらつきが大きく、モデル間の不確実性が顕著に現れている。
また、Sin操舵においては、外力推定分布のばらつきがさらに増大し、真値の時間変化を十分に捉えられていない。

環境場の可視化結果においても同様の傾向が確認される。
旋回試験では、推定された環境場は真値と整合している一方で、直進およびSin操舵では、環境場の方向および大きさに大きな乖離が見られる。

これらの結果は、本提案手法における環境場推定の精度が、予測モデルの再現性に強く依存することを示している。
すなわち、同定に使用した運動と類似した操船条件に対しては高い推定精度が得られる一方で、異なる運動モードに対してはモデル化誤差が増大し、その影響が外力推定の不確実性として顕在化する。

このことから、環境場推定の精度を広範な操船条件において確保するためには、モデル同定段階において多様な運動モード（旋回・直進・加減速等）を含む観測データを用いることで、予測モデルの汎化性能を向上させることが重要である。

=== モデルの不確定性による影響の検証

本項では、予測モデルの同定に用いる平水中データの観測誤差レベルを3段階に変化させることで、モデルの不確定性が環境場推定に与える影響を検証する。
特に、モデル不確定性が外力推定および環境場再構成にどのように伝播するかに着目する。

前項の @fig:observed_data および @fig:calm_water_simulation に示した通り、観測ノイズの大きさに応じて同定される操縦流体力微係数の事後分布の広がりは変化する。
各ノイズレベルで同定された50セットのモデル群を用いて平水中シミュレーションを行った結果を @fig:calm_water_simulation_noise に示す。
観測誤差が最も大きいNoise L1では、パラメータのばらつきが大きく、それに伴い予測軌跡の分布も広がっていることが確認できる。

#figure(
  placement: none,
  image("figs/fig_08.svg", width: 100%),
  caption: [Calm-water simulation with different noise levels.],
) <fig:calm_water_simulation_noise>

次に、これら不確定性の程度が異なる3つの予測モデル群を用い、同一の外乱下データに対して環境場推定を行った。
各ノイズレベルにおける軌道再現結果を @fig:trajectory_tracking_noise に、外力推定結果を @fig:external_force_estimation_noise に、環境場推定結果を @fig:environmental_field_noise に示す。

#figure(
  placement: none,
  image("figs/fig_09.svg", width: 100%),
  caption: [Trajectory tracking result with different noise levels.],
) <fig:trajectory_tracking_noise>

#figure(
  placement: none,
  image("figs/fig_10.svg", width: 100%),
  caption: [External force estimation result with different noise levels.],
) <fig:external_force_estimation_noise>

#figure(
  placement: none,
  image("figs/fig_11.svg", width: 100%),
  caption: [Environmental field result with different noise levels.],
) <fig:environmental_field_noise>

@fig:trajectory_tracking_noise より、いずれの不確定性レベルにおいても、軌道再現自体は良好である。
一方で、外力推定結果および環境場推定結果には、不確定性の程度に応じた明確な差異が確認される。

外力推定結果に着目すると、不確定性が小さい場合には推定分布の幅が狭く、真値を精度良く捉えている。
これに対し、不確定性が増大するにつれて推定分布のばらつきが増加し、モデル間の差異が顕著に現れる。

環境場推定結果においても同様の傾向が見られる。
不確定性が大きい場合には外力ベクトルの分布が広がり、推定結果の不確実性が増大することが視覚的に確認できる。
一方で、代表値に着目すると、不確定性が大きい場合であっても外力の方向や大まかな傾向は概ね捉えられている。

これらの結果は、モデル不確定性が外力推定の分布幅として顕在化する一方で、本手法により得られる代表値は一定のロバスト性を有することを示している。
すなわち、推定結果のばらつきは増加するものの、環境場の主たる傾向は維持される。

したがって、本手法はモデル不確定性を内包した条件下においても、外乱の方向性や強度といった環境場の特徴を一定の精度で再構成可能であるといえる。

== 自由航走模型試験データを用いた検証

本節では、自由航走模型試験で得られた実測データを用いて提案手法の有効性を検証する。
シミュレーションデータとは異なり、本データには計測誤差や未モデル化外乱が含まれるため、より実環境に近い条件下での適用性を評価することを目的とする。

模型船は内航型コンテナ船の一つであり、舵角$-35$度の平水中および規則波中の旋回試験データを使用した。
波向きは$180$度であり、空間固定座標系の$x$軸正方向に対応する。

=== 提案手法のパラメータ設定

船舶操縦運動モデルの同定に用いるMCMC法のパラメータ設定は前節と同様とし、先行研究 #super[@mitsuyuki_mmg_2024] に倣った。

一方で、MPCの設定については、模型試験データの時間分解能および応答特性を考慮し、シミュレーションデータの場合とは異なる値を設定した。
予測ホライゾン、制御周期、制御時間を @tab:mpc_params_model_test に示す。
また、状態誤差および制御入力変化に対する重み行列を @eq:mpc_weights_model_test に示す。

$
  Q &= "diag"(1, 1, 1, 1)\
  R &= "diag"(10^(-4), 10^(-4), 10^(-4))
$ <eq:mpc_weights_model_test>

ここで、シミュレーションケースと比較して$R$を大きく設定することで、実測データに含まれるノイズの影響を抑制し、外力推定の安定性を向上させている。

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

本項では、自由航走模型試験データに対する提案手法の適用結果を示し、実環境に近い条件下における環境場推定の妥当性およびその限界について検証する。

予測モデル群の構築には、舵角$-35$度の平水中旋回試験データを用いた。
平水中観測データを @fig:observed_data_model に示す。
この観測データに対してMCMC法を適用し、操縦流体力微係数を同定した。
微係数の事後分布を @fig:posterior_model に、得られた事後分布から抽出した50セットのモデルを用いた平水中シミュレーション結果を @fig:calm_water_simulation_model に示す。

#figure(
  placement: none,
  image("figs/fig_12.svg", width: 100%),
  caption: [Observed data in calm water.],
) <fig:observed_data_model>

#figure(
  placement: none,
  image("figs/fig_13.svg", width: 100%),
  caption: [Prior and posterior distributions of hydrodynamic coefficients.],
) <fig:posterior_model>

#figure(
  placement: none,
  image("figs/fig_14.svg", width: 100%),
  caption: [Calm-water simulation with identified model parameters.],
) <fig:calm_water_simulation_model>

次に、構築した予測モデル群を用い、規則波中の舵角$-35$度旋回試験データに対して提案手法を適用し、環境場の推定を行った。
軌道再現結果を @fig:trajectory_model に、環境場の推定結果を @fig:environmental_field_model に示す。

#figure(
  placement: none,
  image("figs/fig_15.svg", width: 100%),
  caption: [Trajectory tracking result.],
) <fig:trajectory_model>

#figure(
  placement: none,
  image("figs/fig_16.svg", width: 100%),
  caption: [Environmental field result.],
) <fig:environmental_field_model>

@fig:trajectory_model より、実データにおいても外力項を制御入力として扱うことで、模型船の軌道を良好に再現できていることが確認できる。
一方で、環境場の推定結果には条件に応じた特徴的な差異が見られる。

旋回序盤における向波条件では、推定された代表外力ベクトルは波の進行方向（$x$軸正方向）と概ね一致しており、環境場の方向および大きさを妥当に捉えている。
向波条件では波浪外力が船体運動に対して支配的に作用し、減速などの運動変化が顕著に現れるため、観測データに外乱情報が強く反映されている。
この結果、モデル構造の誤差を上回る情報が得られ、適切な環境場推定が可能となったと考えられる。

一方で、旋回の進行に伴い横波・斜め波条件となる領域では、推定された外力ベクトルの方向が$x$軸正方向から逸脱し、ばらつきが増大する傾向が見られる。
これはパラメータ推定精度の問題ではなく、モデル構造に起因する制約によるものと考えられる。

本研究で用いた3自由度モデルではロール運動を考慮していないが、横波条件では横傾斜に伴う流体力が船体運動に強く影響する。
そのため、ロールに起因する運動変化を、MPCが水平面内の$X, Y, N$成分のみで補正しようとする結果、実際の波向きと整合しない外力が推定されたと解釈できる。

これらの結果から、本提案手法は、外乱の影響が支配的な条件下では実測データからでも妥当な環境場を再構成可能である一方で、モデル構造が外乱応答を十分に表現できない場合には推定精度が制限されることが明らかとなった。

したがって、より一般的な海象条件に対して環境場推定を適用するためには、ロール運動を含む高次自由度モデルへの拡張など、船体運動の表現能力を向上させることが重要である。


= 結論

本研究では、船舶操縦運動モデルが持つ不確定性を考慮した上で、平水中船舶操縦運動モデルと観測データとの差異に基づく逆解析により、船体に作用する外力を帰納的に推定する環境場逆推定フレームワークを提案した。
本手法は、外力を単なる外乱として扱うのではなく、空間的に分布した環境場として再構成する点に特徴を有する。
シミュレーションおよび自由航走模型試験データを用いた検証から、以下の知見を得た。

- 観測データから同定された不確定性を内包するモデル群に対し、外力推定結果の分布から統計的な代表値を抽出することで、物理的に整合した環境場を構築可能であることを示した。また、モデル不確定性が増大した場合でも、代表値に基づく推定により外乱の傾向をロバストに捉えられることを確認した。

- 環境場の推定精度は予測モデルの再現性に強く依存し、同定に用いた運動特性と類似した操船条件に対しては高精度な推定が可能である一方で、異なる運動モードに対してはモデル化誤差が増大し、推定の不確実性が顕在化することを明らかにした。

- 自由航走模型試験データへの適用により、向波のように外乱が支配的な条件下では、実測データからでも妥当な環境場を再構成可能であることを示した。一方で、横波や追い波条件ではロール運動に起因するモデル構造の制約により推定精度が低下することを確認し、モデル拡張の必要性を示した。

以上より、本研究で提案した環境場逆推定フレームワークは、モデル不確定性および観測ノイズを含む実環境下においても、船舶に作用する外乱の空間的特徴を再構成可能であることが示された。
今後は、ロール運動を含む高次自由度モデルへの拡張や、多様な操船データを用いたモデル同定を通じて、より広範な海象条件への適用を目指す。


= 謝　　辞

This work was supported by JSPS KAKENHI Grant Number JP24K07902.

#bibliography("references.bib",
 title: "参　考　文　献",
 style: "libs/jasnaoe-conf/jasnaoe-reference.csl",
 )