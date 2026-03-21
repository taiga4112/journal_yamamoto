#let meta = yaml("paper_info.yaml")
// -----------------------------------------
// Top page
#set page(paper: "a4", columns: 1, margin: (top: 25mm, bottom: 22mm, x: 20mm))
#set text(size: 10pt)

#v(15mm)
#text(size: 16pt, weight: "bold")[#meta.title]
#v(10mm)

#let affiliations = {
  let list = ()
  for a in meta.authors {
    let affs = if type(a.affiliation) == array { a.affiliation } else { (a.affiliation,) }
    for aff in affs {
      if list.position(x => x == aff) == none {
        list.push(aff)
      }
    }
  }
  list
}

#for (idx, a) in meta.authors.enumerate() [
  #let affs = if type(a.affiliation) == array { a.affiliation } else { (a.affiliation,) }
  #let nums = affs.map(aff => affiliations.position(x => x == aff) + 1)
  #let nums-text = nums.map(n => str(n)).join(",")

  #a.name#super[#nums-text]
  #if idx < meta.authors.len() - 1 [
    #h(1.0em)
  ]
]


#v(4mm)
#for (i, aff) in affiliations.enumerate() [
  #super[#(i + 1)] #aff
  #linebreak()
]

#v(12mm)
#text(weight: "bold")[Abstract]
#v(4mm)
#align(left)[#meta.abstract]

#pagebreak()

//------------------------------------------

#import "libs/jasnaoe-conf/jasnaoe-conf_lib.typ": jasnaoe-conf
#show: jasnaoe-conf.with()

#import "libs/jasnaoe-conf/direct_bib_lib.typ": bibliography-list, bib-item, use-bib-item-ref
#show: use-bib-item-ref.with(numbering: "1)") // 番号の書式を指定

= Introduction

In the maritime industry, it has been widely recognized that approximately 80% of marine accidents are attributed to human factors.
At the same time, structural challenges, including crew shortages and an aging workforce, remain significant and persistent issues.
To address these issues, extensive research and development efforts have been devoted to the realization of autonomous ships #super[@burmeister_autonomous_2014 @felski_ocean-going_2020].
Autonomous ships are required to execute advanced maneuvering tasks, such as trajectory tracking and collision avoidance, which have traditionally been performed by human operators.
Achieving this capability requires not only advanced control strategies but also an accurate understanding of ship maneuvering performance from the design stage.
Therefore, ship maneuvering models play a fundamental role in both motion prediction and control.

Ship maneuvering models have been widely used for trajectory prediction and control, and various modeling approaches have been developed #super[@hao_recurrent_2022 @liu_predictions_2018 @wang_non-parameterized_2023].
However, these models primarily describe ship behavior in calm water and do not fully capture environmental disturbances in real sea conditions.

Conventionally, ship maneuvering models have been identified through PMM (Planar Motion Mechanism) tests #super[@ZHU2022103327], captive model tests (CMT) #super[@ueno_circular_2009], or computational fluid dynamics (CFD) analyses #super[@kume_measurements_2006].
These approaches enable highly accurate identification of hydrodynamic maneuvering coefficients under specific operating conditions.
However, in actual operations, ship conditions vary due to factors such as loading conditions, ballast changes, and operational environments, leading to variations in hydrodynamic parameters.
Data-driven identification methods using onboard observations have been proposed to address this issue #super[@hasan_discovering_2025 @REN2023109422], but the identified models inevitably include uncertainty due to measurement noise and data limitations #super[@mitsuyuki_mmg_2024].

In real sea conditions, environmental factors such as wind, waves and currents play a dominant role in ship motion.
Although these effects are typically treated as disturbances, they are not merely noise but phenomena with temporal and spatial structures.
In conventional maneuvering models such as the MMG model #super[@yasukawaIntroductionMMGStandard2015], Fossen model #super[@fossen_nonlinear_1995 @fossen_handbook_2011] and Abkowitz model #super[@abkowitz_measurement_1980], environmental effects are commonly represented as additional external force terms superimposed on calm-water dynamics #super[@yasukawa_application_2020 @suzuki_numerical_2021 @yasukawa_evaluations_2019 @paroka_prediction_2017].
These external forces are usually estimated deductively using environmental information such as wind, waves and currents.
However, even with wave buoys or satellite observations, it remains difficult to obtain accurate, real-time, and local environmental information along a ship’s trajectory.
Furthermore, disturbance models derived from model-scale experiments inherently contain modeling errors and cannot fully represent the complexity of real sea environments.
As a result, discrepancies arise between simulated ship motions and observed behaviors.
These discrepancies are not solely due to model errors but are also attributed to the uncertainty in the representation and estimation of environmental forces, highlighting the limitation of conventional forward modeling approaches in real sea conditions.

On the other hand, recent advances in onboard measurement technologies such as GPS and voyage data recorders have enabled the acquisition of abundant observational data, including ship position and velocity #super[@vu_estimating_2023 @mei_full-scale_2020].
Although these observations include measurement uncertainty, they directly reflect the actual ship motion influenced by both vessel dynamics and environmental factors.
This suggests that external forces can be inferred directly from observational data, enabling environmental effects to be reconstructed without relying on explicit environmental measurements.
The inferred forces can be interpreted not merely as time-series disturbances, but as spatially distributed quantities that encode environmental structure along the ship trajectory.

In this study, an environmental field reconstruction framework is proposed based on inverse estimation of external forces using observational data.
The unknown external forces are treated as control inputs and estimated by formulating an optimization problem that minimizes the discrepancy between observed and predicted ship motion over a finite horizon.
This formulation enables temporally consistent estimation of external forces.
The environmental field is defined not as individual physical quantities such as wind speed or wave height, but as the resultant forces and moments acting on the ship, including the horizontal force vector (magnitude and direction) and yaw moment.
By associating the estimated forces with the ship’s position and time, the environmental effects are reconstructed as spatially distributed information.

The main contributions of this study are summarized as follows.
First, environmental field reconstruction is formulated as an inverse problem based on ship maneuvering data.
Second, an external force estimation method is developed using model predictive control, where external forces are treated as control inputs.
Third, model uncertainty is incorporated through a probabilistic system identification approach, enabling multi-model-based estimation.
Finally, a representative external force is determined using a medoid-based selection method that preserves the correlation structure among force components.

This framework provides a new perspective on environmental estimation by shifting from forward modeling to inverse reconstruction based on ship motion data.

= Related Studies

== System Identification of Maneuvering Models with Uncertainty

This section reviews studies on the system identification of ship maneuvering models.
When identifying ship maneuvering models using observational data obtained in real sea conditions, the data inevitably include uncertainty such as measurement noise.
Therefore, it is difficult to determine model parameters as unique deterministic constants.

To address this issue, Mitsuyuki et al.#super[@mitsuyuki_mmg_2024] proposed a method based on Markov Chain Monte Carlo (MCMC) for estimating hydrodynamic maneuvering coefficients in the MMG model from noisy observational data.
In this approach, hydrodynamic maneuvering coefficients are treated not as deterministic values but as random variables with associated uncertainty.

To account for measurement errors in observational data, the following probabilistic observation model is defined using independent normal distributions.

$
u_italic("obs")(t)~N(u(t), sigma_u)\
v_italic("obs")(t)~N(v(t), sigma_v)\
r_italic("obs")(t)~N(r(t), sigma_r)
$ <eq:observation_model>

Here, $u_italic("obs")(t), v_italic("obs")(t), r_italic("obs")(t)$ denote the observed velocity components at time $t$, $u(t), v(t), r(t)$ represent the true values, and $sigma_u, sigma_v, sigma_r$ are the standard deviations of the measurement noise.

By combining this observation model with MCMC-based sampling, multiple sets of hydrodynamic maneuvering coefficients can be obtained while explicitly accounting for observational uncertainty.
In this study, the same MCMC-based approach is employed to construct uncertain calm-water maneuvering models from observational data.
These models are then used as uncertainty-aware predictive models for external force estimation in the proposed framework.

== External Force Estimation

This section reviews existing approaches for estimating unknown external forces based on discrepancies between observational data and mathematical models, and clarifies the position of this study.

Environmental information such as wind, waves and currents can be obtained using wave buoys or satellite observations #super[@ERA5_global_2020].
However, these measurements are typically limited to fixed locations or large-scale observations, making it difficult to accurately capture local disturbances acting on a ship during navigation.
Furthermore, equipping all vessels with high-precision measurement systems is impractical from both cost and operational perspectives.

Motivated by these limitations, approaches have been proposed to estimate external forces based on the difference between observed data and model outputs.
Among them, disturbance observer (DOB)-based methods have been widely studied #super[@gu_disturbance_2022 @menges_environmental_2023].
DOB estimates unknown disturbances based on the residual between observed states and model predictions, and is suitable for real-time applications.

However, in DOB-based approaches, external forces are typically estimated independently at each time step based on instantaneous residuals.
As a result, the estimates are sensitive to measurement noise and tend to exhibit oscillatory behavior due to noise sensitivity.
In addition, the estimated forces are often treated as time-series signals, and their spatial structure or physical interpretation is not explicitly considered.

Another class of approaches is based on Moving Horizon Estimation (MHE)#super[@liu_moving_2025 @SCHILLER2024341], where states and disturbances are estimated over a finite time window.
Since MHE is formulated as an optimization problem over a finite horizon, it is more robust to noise and can enforce temporal consistency in the estimation.
However, MHE is primarily designed for state estimation, and external forces are often treated as auxiliary variables introduced to explain the observations.

In contrast, the external forces considered in this study, such as those induced by wind, waves and currents, are not negligible disturbances but can have a dominant impact on ship maneuvering.
These forces possess temporal and spatial structures and should therefore be explicitly treated as primary estimation targets rather than auxiliary variables.

For this reason, this study adopts an approach in which external forces are explicitly treated as control inputs and estimated using a model predictive control (MPC)#super[@rawlings_mpc_2017 @QIN2003733] framework.
Specifically, external forces are obtained by solving an optimization problem that minimizes the discrepancy between observed data and model predictions over a finite horizon.
This formulation enables the estimation of temporally consistent force sequences, in contrast to stepwise estimation based on instantaneous residuals.

Furthermore, the objective of this study is not limited to time-series estimation of external forces.
By associating the estimated forces with vessel position data, the forces are reconstructed as spatially distributed environmental fields.
Unlike conventional disturbance estimation or state estimation approaches, this study reformulates external force estimation as an inverse problem, enabling environmental field reconstruction.


= Proposed Method

== Overview

#figure(
  placement: bottom,
  image("figs/fig_01.svg", width: 100%),
  caption: [Overview of the proposed method.],
) <fig:proposed_method>

An overview of the proposed method is shown in @fig:proposed_method.
The proposed framework formulates environmental field reconstruction as an inverse problem based on observational data obtained from a ship operating in real sea conditions and mathematical models with inherent uncertainty.

First, observational data such as ship position and velocity, as well as control input data including rudder angle and propeller rotation speed, are obtained from onboard measurement systems such as voyage data recorder.

Next, the control inputs are applied to the predictive model to simulate future ship motion.
In the proposed method, external forces are estimated by formulating an optimization problem that minimizes the discrepancy between observed data and predicted motion over a finite horizon.
The cost function consists of the difference between observed ship states and model outputs, as well as a penalty term on the temporal variation of external forces treated as control inputs.
This penalty suppresses non-physical rapid fluctuations and enables the estimation of temporally consistent force sequences.

The predictive model is constructed by augmenting a calm-water ship maneuvering model with external force terms.
The optimal external forces are obtained by minimizing the cost function, and the ship motion is sequentially updated using the estimated forces to generate time-series data of external forces.

In real operations, ship dynamics vary depending on loading conditions and operating environments.
Therefore, the proposed method employs models identified from observational data as predictive models.
The identification is performed using the MCMC-based probabilistic system identification method  ddddd#super[@mitsuyuki_mmg_2024] described in the previous section, yielding multiple sets of hydrodynamic maneuvering coefficients representing model uncertainty.

To account for model uncertainty, multiple predictive models with different hydrodynamic maneuvering coefficient sets are prepared, and external force estimation using MPC is performed for each model.
This approach yields multiple time-series estimates of external forces reflecting model uncertainty.

Finally, representative values are extracted from the distribution of estimated forces and associated with the ship’s position.
By linking force estimates with spatial coordinates, the external forces are reconstructed as spatially distributed environmental fields.

== Predictive Model Formulation

This section presents the predictive model used in the model predictive control (MPC) framework and the treatment of model uncertainty.

As described in the previous section, the proposed method employs multiple predictive models with different sets of hydrodynamic maneuvering coefficients.
Each predictive model is based on a three-degree-of-freedom MMG model in calm water, augmented with external force terms.

In the conventional MMG model for ship maneuvering, ship motion is described as the sum of hull forces $H$, rudder forces $R$, and propeller thrust $P$.
In this study, external force components $(X_F, Y_F, N_F)$ are explicitly introduced, and the governing equations are expressed as follows.

$
dot(u)&=(X_H+X_R+X_P+X_F+(m+m_y)v r)/(m+m_x) \
dot(v)&=(Y_H+Y_R+Y_F-(m+m_x)u r)/(m+m_y) \
dot(r)&=(N_H+N_R+N_F)/(I_z+J_z)
$<eq:predictive_model>

Here, the hydrodynamic force components $(X_H, Y_H, N_H)$ are expressed as functions of hydrodynamic maneuvering coefficients #super[@yasukawaIntroductionMMGStandard2015].
In the proposed method, multiple predictive models are constructed by substituting different sets of hydrodynamic maneuvering coefficients obtained through MCMC-based identification into these force components, while maintaining the same functional structure.

Next, the state variables used in the MPC framework are defined.
In this study, the ship is assumed to be a rigid body, and its planar motion is described by three degrees of freedom, namely surge, sway, and yaw.

The position and orientation of the ship can be represented as geometric information on a plane.
Therefore, the state variables can be defined as a finite set of variables based on spatial coordinates.
Although the choice of state representation is not unique, a four-dimensional state vector defined by the positions of the bow and stern is adopted here as a representative example, as it provides a geometrically intuitive and numerically stable description of both translational and rotational motion.

$
bold(x) = [x_b, y_b, x_s, y_s]^T
$

This representation enables a geometric description of both translational and rotational motion of the ship.
The state definition is not restricted to the proposed framework, and alternative coordinate systems or state representations can also be employed.

These coordinates are computed from the body-fixed velocities and angular velocity $(u, v, r)$, the heading angle $psi$, and the geometric properties of the ship through kinematic relationships.

The external force components $(X_F, Y_F, N_F)$ are treated as the control input vector in the MPC formulation.

$
bold(u) = [X_F, Y_F, N_F]^T
$

Accordingly, the time evolution of the state variables is described as a nonlinear dynamical system with control inputs in continuous time as follows.

$
dot(bold(x))(t)=f(bold(x)(t),bold(u)(t))
$<eq:state_variables_derivative>

== External Force Estimation Using MPC

This section presents the external force estimation method based on a model predictive control (MPC) framework.
In the proposed method, external forces are treated as control inputs and estimated so that the predicted ship motion is consistent with the observed data.

The objective is not trajectory tracking but to derive a sequence of external forces that best explains the observed ship motion.
Therefore, the problem is formulated as an inverse problem.

First, the continuous-time model is discretized with a control interval $Delta t$, resulting in the discrete-time model shown in @eq:discrete_model.
This results in the following discrete-time model.

$
bold(x)_(t+1)=F(bold(x)_t, bold(u)_t)
$<eq:discrete_model>

Next, the cost function for the external force estimation is defined.
In this study, the cost function consists of a tracking error term that penalizes the discrepancy between the predicted and observed states, and a regularization term that penalizes the temporal variation of the control inputs representing external forces.


Let the prediction horizon be $N$.
The external force estimation problem is formulated as the following optimization problem.
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
    )
$ <eq:mpc_optimization_problem>

Here, $bold(e)_(t+k)$ denotes the state error at time $t+k$, and $bold(x)_(t+k)^(italic("ref"))$ represents the reference state obtained from observational data at time $t+k$.
$bold(x)_("init")$ denotes the initial state.
$Delta bold(u)_(t+k)$ represents the temporal variation of the control inputs as follows:
$
Delta bold(u)_(t+k) = bold(u)_(t+k) - bold(u)_(t+k-1)
$
The initial input $bold(u)_t$ is given from the previous time step.
No explicit constraints are imposed on the control inputs, as the regularization term ensures physically reasonable solutions.
This formulation avoids additional constraint tuning while maintaining smooth and stable force estimation.

The weighting matrices $bold(Q)$ and $bold(R)$ correspond to the state error and input variation, respectively.
By adjusting these weights, the characteristics of the estimated external force sequence can be controlled.
A larger $bold(Q)$ improves the agreement with observed data but may result in larger fluctuations in the estimated forces.
In contrast, a larger $bold(R)$ suppresses rapid variations in the external forces and yields smoother force sequences.

By solving this optimization problem sequentially at each time step, a temporally consistent and physically plausible sequence of external forces can be obtained.

== Environmental Field Reconstruction

In this study, the environmental field is defined as the spatial distribution of external forces acting on the vessel along its trajectory.
By applying MPC to $n$ predictive models that account for model uncertainty, $n$ sets of estimated external forces are obtained at each time step $t$ as follows.

$
(X_(F_t)^(i), Y_(F_t)^(i), N_(F_t)^(i)), quad i=1,2,...,n
$

This section describes the method for determining representative external forces from these distributions and constructing the environmental field.

A common approach for determining representative values from multiple estimates is to use statistical measures such as the mean or median.
However, these methods process each component independently and may destroy the correlation structure among the force components, resulting in physically inconsistent combinations.

To address this issue, the proposed method treats the three force components as a single vector and selects one of the estimated force vectors that is closest to the center of the distribution in terms of pairwise distances.
This can be interpreted as a robust estimation of a representative point in a multidimensional space, analogous to the concept of a medoid.

Each component is normalized to ensure comparable scaling among the force components, for example by dividing by characteristic magnitudes.
Specifically, for the $i$-th normalized force vector at time $t$

$
(tilde(X_(F_t))^(i), tilde(Y_(F_t))^(i), tilde(N_(F_t))^(i))
$

the sum of Euclidean distances to all other estimates is defined as follows.

#set text(size: 7.5pt)
$
D_i (t)= sum_(j=1)^(n) sqrt(
(tilde(X_(F_t))^(i)-tilde(X_(F_t))^(j))^2 +
(tilde(Y_(F_t))^(i)-tilde(Y_(F_t))^(j))^2 +
(tilde(N_(F_t))^(i)-tilde(N_(F_t))^(j))^2
)
$<eq:distance_sum>
#set text(size: 9pt)

The index $i^*$ that minimizes $D_i(t)$ is selected, and the corresponding actual force vector

$
(X_(F_t)^(i^*), Y_(F_t)^(i^*), N_(F_t)^(i^*))
$

is defined as the representative external force at time $t$.

This approach suppresses the influence of outliers while preserving the inherent correlation structure among the force components, which is essential for maintaining physical consistency.

Finally, the representative external forces at each time step are transformed into the earth-fixed coordinate system.
This enables the external forces acting on the ship to be associated with spatial positions and represented as an environmental field.

The magnitude $E F_italic("mag")$, direction $E F_italic("dir")$, and moment $E F_italic("mom")$ of the resultant force vector are defined as follows.

$
E F_italic("mag")_t &= sqrt(X_F(italic("Earth"))_t^2 + Y_F(italic("Earth"))_t^2)\
E F_italic("dir")_t &= tan^(-1)(Y_F(italic("Earth"))_t / X_F(italic("Earth"))_t)\
E F_italic("mom")_t &= N_F(italic("Earth"))_t
$ <eq:environmental_field>

Through this process, the estimated external force sequence is reconstructed as a spatial distribution along the ship trajectory.
That is, the set $(E F_italic("mag")_t, E F_italic("dir")_t, E F_italic("mom")_t)$ represents the environmental effects acting on the ship at each position.

In this way, the proposed method extends external force estimation beyond time-series analysis and formulates it as a reconstruction problem of spatially distributed environmental fields.


= Case Study

In this section, case studies using both simulation data and experimental data are conducted to validate the effectiveness and applicability of the proposed method.

In real operations, ship conditions and environmental factors vary for each voyage, and therefore models identified in advance through captive tests or tank experiments are  not necessarily applicable without re-identification.
For this reason, the proposed framework assumes that both model identification and external force estimation are performed based on observational data obtained during actual voyages.

Specifically, it is assumed that a single voyage dataset can be segmented into periods corresponding to calm-water conditions with relatively small disturbances and periods strongly affected by environmental disturbances such as wind and waves.
First, the MCMC-based identification method is applied to the calm-water segments to estimate the distribution of hydrodynamic maneuvering coefficients and construct multiple predictive models.
Next, the proposed method is applied to the disturbance segments to estimate the time-series external forces and reconstruct the environmental field.

In this case study, model identification and external force estimation are performed separately under conditions that emulate real operational scenarios.
This setup enables a systematic evaluation of the proposed framework under realistic operational conditions.

== Validation Using Simulation Data

In this section, the fundamental performance and estimation accuracy of the proposed method are quantitatively evaluated using simulation data in which the ground-truth external forces are known.
Here, the ground truth refers to the external force components explicitly given in the mathematical model.

=== Generation of Observational Data

This subsection describes the procedure for generating observational data used in the validation.
In this study, a dataset including both calm-water segments and disturbance segments is artificially generated to emulate real operational conditions.
The full-scale KCS container ship is used for data generation.
Its principal particulars are described in Okuda et al. #super[@okuda_validation_2023].

First, the generation of calm-water observational data is described.
A three-degree-of-freedom MMG simulation in calm water is performed using the hydrodynamic maneuvering coefficients of the target vessel, and the resulting motion data are used as the basis of the observational dataset.
To emulate measurement errors in onboard sensors, zero-mean white Gaussian noise is added to the velocity components $u, v, r$, and the resulting data are treated as observational data.

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

Next, observational data under disturbance conditions including wind and wave effects are generated.
Wind forces are calculated using the estimation formula proposed by Fujiwara et al. #super[@fujiwara_experimental_nodate], and wave-induced steady forces are computed using the method proposed by Yasukawa et al. #super[@yasukawa_validation_2021].
These forces are treated as ground-truth external forces and incorporated into the right-hand side of the equations of motion for simulation.
The disturbance conditions used in this validation are summarized in @tb:disturbance_conditions.
In the earth-fixed coordinate system, the positive $x$-axis is defined as 0 degrees, and the clockwise direction is taken as positive.

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

The proposed method is applied to the generated disturbance dataset to evaluate the accuracy of external force estimation and the capability of environmental field reconstruction.

=== Parameter Settings of the Proposed Method

This subsection describes the parameter settings for the MCMC-based identification and the model predictive control (MPC) used for environmental field estimation.

First, the prior distributions of the hydrodynamic maneuvering coefficients required for the MCMC-based identification are defined.
To avoid bias toward specific parameter values, uniform distributions are assigned following the approach in previous work #super[@mitsuyuki_mmg_2024].
The number of samples is set to 1500, and the initial 500 samples are discarded as burn-in to remove non-converged samples.
From the resulting posterior distribution, 50 sets of hydrodynamic maneuvering coefficients are randomly selected and used to construct multiple predictive models reflecting model uncertainty.

Next, the parameter settings for the MPC are described.
The prediction horizon $N$, control interval $Delta t$, and control duration $T$ are summarized in @tab:mpc_params.
The prediction horizon is determined by considering the trade-off between computational cost and temporal consistency.

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

The state variables are defined based on the assumption that the ship is a rigid body, using the $x$ and $y$ coordinates of the bow and stern.

The weighting matrices $bold(Q)$ and $bold(R)$ for the state error and the variation of control inputs are defined as follows.

$
  bold(Q) &= "diag"(1, 1, 1, 1)\
  bold(R) &= "diag"(10^(-5), 10^(-5), 10^(-5))
$ <eq:mpc_weights>

Here, $bold(Q)$ controls the degree of agreement with the observational data, while $bold(R)$ regulates the smoothness of the temporal variation of external forces.
In this study, these parameters are selected to prioritize consistency with observational data while suppressing non-physical oscillations in the estimated external forces.

=== Effect of Maneuvering Conditions on Estimation Accuracy

This subsection investigates the impact of different maneuvering conditions on the accuracy of environmental field estimation.
In particular, the performance of the proposed method is examined when it is applied to maneuvering conditions that differ from those used for model identification.

Using the set of predictive models identified from turning test data in calm water, environmental field estimation is performed for three different maneuvering conditions under disturbances: a 20-degree turning maneuver, sinusoidal rudder input, and straight-line motion.
The estimation accuracy is then compared across these cases.

The initial conditions of the 20-degree turning test used for model identification are given as follows:
the initial surge velocity $u_0 = 10.4 "m/s"$, sway velocity $v_0 = 0.0 "m/s"$, and yaw rate $r_0 = 0.0 "rad/s"$,
with propeller revolution $n_p = 1.75 "rps"$ and rudder angle $delta = 20 "deg"$.
The observational data are generated under the Noise L2 condition.

The calm-water turning data are shown in @fig:observed_data.
The MCMC method is applied to this dataset to identify the hydrodynamic maneuvering coefficients.

#figure(
  placement: none,
  image("figs/fig_02.svg", width: 100%),
  caption: [Observed data in calm water.],
) <fig:observed_data>

#figure(
  placement: none,
  image("figs/fig_03.svg", width: 100%),
  caption: [Prior and posterior distributions of hydrodynamic maneuvering coefficients.],
) <fig:posterior_distributions>

#figure(
  placement: none,
  image("figs/fig_04.svg", width: 100%),
  caption: [Calm-water simulation using the identified hydrodynamic maneuvering coefficients.],
) <fig:calm_water_simulation>

The posterior distributions of the hydrodynamic maneuvering coefficients are shown in @fig:posterior_distributions, and the calm-water simulation results using 50 model sets sampled from the posterior distribution are presented in @fig:calm_water_simulation.
All models successfully reproduce the trajectory of the observed data with good agreement, indicating that a set of predictive models has been constructed that is both physically consistent and capable of representing uncertainty arising from observational noise.
Next, the proposed method is applied to disturbance data under different maneuvering conditions using the identified predictive model set.
The trajectory reconstruction results for each maneuvering condition are shown in @fig:trajectory_tracking, the estimated external forces are presented in @fig:external_force_estimation , and the reconstructed environmental fields are shown in @fig:environmental_field.

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

As shown in @fig:trajectory_tracking, the trajectory reconstruction agrees well with the observed data for all maneuvering conditions.
However, clear and systematic differences are observed in the external force estimation results and the reconstructed environmental fields depending on the maneuvering condition.

In the turning test, both the temporal profiles of the estimated external forces and the magnitude and direction of the reconstructed environmental field show good agreement with the ground truth.
In contrast, in the straight-line motion case, $Y_F$ and $N_F$ converge close to the ground truth, while $X_F$ exhibits a large variance in the estimated distribution, indicating pronounced model uncertainty.
Furthermore, in the sinusoidal rudder case, the variance of the estimated external force distribution increases further, and the temporal variation of the ground truth is not sufficiently captured.

A similar trend is observed in the visualization of the environmental field.
In the turning test, the reconstructed environmental field is consistent with the ground truth, whereas in the straight-line and sinusoidal rudder cases, significant discrepancies are observed in both magnitude and direction.

These results indicate that the accuracy of environmental field estimation in the proposed method strongly depends on the predictive capability and generalization performance of the model.
Specifically, high estimation accuracy is achieved for maneuvering conditions similar to those used in the model identification, whereas for different motion modes, modeling errors increase and manifest as uncertainty in the external force estimation.

Therefore, to ensure robust environmental field estimation across a wide range of maneuvering conditions, it is essential to improve the generalization capability of the predictive model by incorporating observational data that include diverse motion modes, such as turning, straight motion, and acceleration/deceleration, during the model identification stage.


==== Impact of Model Uncertainty

This subsection investigates the effect of model uncertainty on environmental field estimation by varying the observation noise level of the calm-water data used for model identification across three levels.
In particular, the propagation of model uncertainty into external force estimation and environmental field reconstruction is examined.

As shown in @fig:observed_data and @fig:calm_water_simulation, the spread of the posterior distributions of the hydrodynamic maneuvering coefficients varies depending on the magnitude of observational noise.
The calm-water simulation results using 50 model sets identified under each noise level are presented in @fig:calm_water_simulation_noise.
In the case of Noise L1, where the observation error is the largest, the variance of the identified parameters increases significantly, resulting in a wider spread of the predicted trajectories.

#figure(
  placement: none,
  image("figs/fig_08.svg", width: 100%),
  caption: [Calm-water simulation with different noise levels.],
) <fig:calm_water_simulation_noise>

Next, environmental field estimation is performed for the same disturbance dataset using three sets of predictive models with different levels of uncertainty.
The trajectory reconstruction results for each noise level are shown in @fig:trajectory_tracking_noise, the estimated external forces are presented in @fig:external_force_estimation_noise, and the reconstructed environmental fields are shown in @fig:environmental_field_noise.

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

As shown in @fig:trajectory_tracking_noise, the trajectory reconstruction remains accurate across all levels of model uncertainty.
In contrast, clear differences are observed in the external force estimation and environmental field reconstruction results depending on the level of uncertainty.

Focusing on the external force estimation results, when the model uncertainty is small, the estimated distributions are narrow and accurately capture the ground truth.
As the level of uncertainty increases, the spread of the estimated distributions becomes larger, and discrepancies among models become more pronounced.

A similar trend is observed in the environmental field reconstruction.
With higher uncertainty, the distribution of the estimated force vectors becomes more dispersed, indicating an increase in estimation uncertainty.
However, when focusing on the representative values, the overall direction and general trend of the external forces are still reasonably captured even under high uncertainty.

These results indicate that model uncertainty manifests as increased dispersion in the estimated external forces, while the representative values obtained by the proposed method exhibit a certain degree of robustness.
In other words, although the variability of the estimates increases, the dominant characteristics of the environmental field are preserved.

Therefore, the proposed method is capable of reconstructing key features of the environmental field, such as the direction and magnitude of disturbances, with reasonable accuracy even under conditions with significant model uncertainty.


=== Validation Using Free-Running Model Test Data

This section validates the proposed method using measured data obtained from free-running model tests.
Unlike simulation data, the experimental data include measurement noise and unmodeled disturbances, and thus are used to evaluate the robustness and practical applicability of the proposed method under realistic operational conditions.
The model ship is a coastal container vessel, and turning test data with a rudder angle of $-35$ degrees in both calm water and regular waves are used.
The wave direction is $180$ degrees, corresponding to the positive $x$-axis in the earth-fixed coordinate system.

=== Parameter Settings of the Proposed Method

The parameter settings for the MCMC-based identification of the ship maneuvering model are the same as those used in the previous section, following the approach in #super[@mitsuyuki_mmg_2024].

In contrast, the MPC parameters are adjusted considering the temporal resolution and dynamic response characteristics of the model test data, and differ from those used in the simulation cases.
The prediction horizon, control interval, and control duration are summarized in @tab:mpc_params_model_test.
The weighting matrices for the state error and the variation of control inputs are defined in @eq:mpc_weights_model_test.

$
  bold(Q) &= "diag"(1, 1, 1, 1)\
  bold(R) &= "diag"(10^(-4), 10^(-4), 10^(-4))
$ <eq:mpc_weights_model_test>

Here, compared to the simulation case, larger values of $bold(R)$ are adopted to suppress the influence of noise contained in the experimental data and to improve the stability of external force estimation.
This reflects a trade-off between tracking accuracy and noise robustness, which becomes more critical in experimental conditions.

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


=== Estimation Results

This subsection presents the results of applying the proposed method to free-running model test data, and examines the validity and limitations of environmental field reconstruction under conditions close to real operational environments.

The predictive model set is constructed using calm-water turning test data with a rudder angle of $-35$ degrees.
The observed calm-water data are shown in @fig:observed_data_model.
The MCMC method is applied to this dataset to identify the hydrodynamic maneuvering coefficients.
The posterior distributions of the identified parameters are shown in @fig:posterior_model, and the calm-water simulation results using 50 model sets sampled from the posterior distribution are presented in @fig:calm_water_simulation_model.

#figure(
  placement: none,
  image("figs/fig_12.svg", width: 100%),
  caption: [Observed data in calm water.],
) <fig:observed_data_model>

#figure(
  placement: none,
  image("figs/fig_13.svg", width: 100%),
  caption: [Prior and posterior distributions of hydrodynamic maneuvering coefficients.],
) <fig:posterior_model>

#figure(
  placement: none,
  image("figs/fig_14.svg", width: 100%),
  caption: [Calm-water simulation with identified model parameters.],
) <fig:calm_water_simulation_model>

Next, the proposed method is applied to the turning test data with a rudder angle of $-35$ degrees in regular waves using the constructed predictive model set, and the environmental field is reconstructed.

The trajectory reconstruction results are shown in @fig:trajectory_model, and the reconstructed environmental field is presented in @fig:environmental_field_model.

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

As shown in @fig:trajectory_model, the trajectory of the model ship can be well reproduced even with experimental data by treating the external forces as control inputs.
In contrast, the reconstructed environmental fields exhibit characteristic differences depending on the wave conditions.

Under head-wave conditions in the early stage of the turning motion, the estimated representative external force vectors are generally aligned with the wave propagation direction (positive $x$-axis), indicating that both the direction and magnitude of the environmental field are reasonably captured.
In head-wave conditions, wave-induced forces dominantly affect the ship motion, and motion changes such as deceleration are clearly observed.
As a result, disturbance information is strongly reflected in the observed data, allowing the estimation to partially compensate for model inaccuracies and achieve reasonable environmental field reconstruction.

On the other hand, as the turning motion progresses into beam and oblique wave conditions, the direction of the estimated external force vectors deviates from the positive $x$-axis, and the dispersion of the estimates increases.
This behavior is not attributed to parameter estimation accuracy, but rather to inherent limitations in the model structure.

The 3-DOF model used in this study does not account for roll motion, whereas in beam-wave conditions, roll-induced hydrodynamic effects significantly influence the ship motion.
Consequently, the MPC attempts to compensate for these effects using only the in-plane components ($X, Y, N$), leading to estimated external forces that are not consistent with the actual wave direction.

These results indicate that the proposed method can reconstruct a reasonable environmental field from experimental data when disturbances are dominant, while the estimation accuracy is limited when the model structure cannot adequately represent the disturbance response.
This highlights both the practical effectiveness and the inherent limitations of the proposed framework under realistic conditions.

Therefore, to extend the applicability of the method to more general sea conditions, it is important to enhance the model representation capability, for example by extending the model to higher degrees of freedom including roll motion.


= Conclusion

This study proposed an inverse environmental field reconstruction framework that estimates external forces acting on a ship from the discrepancy between a calm-water maneuvering model and observed data while accounting for model uncertainty.
Unlike conventional approaches that treat external forces as disturbances, the proposed method explicitly reconstructs them as a spatially distributed environmental field.

From validation using both simulation data and free-running model test data, the following findings were obtained.

- By extracting a representative value from the distribution of estimated external forces obtained from a set of uncertainty-aware predictive models identified from observational data, a physically consistent environmental field can be constructed. Even under increased model uncertainty, the representative-value-based approach enables robust capture of disturbance trends.

- The accuracy of environmental field reconstruction strongly depends on the predictive capability of the model. High estimation accuracy is achieved under maneuvering conditions similar to those used for model identification, whereas for different motion modes, modeling errors increase and manifest as increased uncertainty in the estimation results.

- Application to free-running model test data demonstrated that the proposed method can reconstruct a physically reasonable environmental field from experimental data under disturbance-dominant conditions such as head waves. In contrast, under beam and following wave conditions, the estimation accuracy decreases due to limitations in the model structure associated with neglecting roll motion, highlighting the need for model extension.

These results demonstrate that the proposed framework provides a practical and robust approach for reconstructing the spatial characteristics of disturbances acting on a ship under realistic conditions with model uncertainty and observational noise.

Future work includes extending the model to higher degrees of freedom incorporating roll motion and improving model generalization by using diverse maneuvering data for model identification, thereby enhancing the applicability of the framework to a wider range of sea conditions.


= Acknowledgements

This work was supported by JSPS KAKENHI Grant Number JP24K07902 and the Japan Science and Technology Agency Moonshot R&D Program Grant JPMJMS2282.

#bibliography("references.bib",
 title: "References",
 style: "libs/jasnaoe-conf/jasnaoe-reference.csl",
 )