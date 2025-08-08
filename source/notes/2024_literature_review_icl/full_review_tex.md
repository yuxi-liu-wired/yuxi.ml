\documentclass[12pt]{article}
\usepackage[english]{babel}
\usepackage{mathtools, amsmath, amsthm, amssymb, amsfonts}
\begin{document}
\section{Overview}

As the starting point of our research is \cite{gargWhatCanTransformers2022}, we made an exhaustive literature review of all 223 papers that has cited it at the time of writing (2024-04-18). We categorize them into the following classes.

\begin{enumerate}
	\item \textbf{Bayes and generalization:} Many papers showed that the trained model acts like a Bayes optimal predictor with a prior fitted to the training set. However, a few papers showed that models can learn to generalize beyond the specific ICL tasks presented in the training set. They typically find that models, when trained on enough variety of ICL tasks, can generalize, and perform better on the test set than predictors that are Bayes-optimal on the training set.
	\item \textbf{Mechanistic interpretation:} These papers investigate the internal mechanisms of trained models, particularly how they encode information and perform computations within their layers. They often find that the trained model performs Bayes-optimal prediction.
	\item \textbf{Theoretical foundations:} These papers contain formal proofs about the learning dynamics and generalization properties of ICL models, typically by heavy linear algebra.
	\item \textbf{Empirical improvement:} These papers empirically explore how to improve ICL performance by varying dataset composition, model architecture, curriculum learning strategies, etc.
	\item \textbf{Irrelevant:} These papers are ignored. They typically cite \cite{gargWhatCanTransformers2022} in a perfunctory paragraph in the perfunctory literature review.
\end{enumerate}

Most subsequent work follows \cite{gargWhatCanTransformers2022} in training GPT-2-like transformers on ICL with linear regression tasks, so this is the default setting. We only note where they differed.

\section{Previous work}

This section reviews precedent works that are most relevant for \cite{gargWhatCanTransformers2022} and its descendant works.

\subsection{Empirical Findings}

The widespread interest in ICL started with \cite{brownLanguageModelsAre2020}, which demonstrated the potential of ICL with GPT-3. Subsequent work, such as \cite{weiFinetunedLanguageModels2022}, has further improved ICL capabilities through instruction tuning, while \cite{kojimaLargeLanguageModels2022} introduced chain-of-thought (CoT) prompting, triggering widespread interest in prompt engineering.

\cite{minRethinkingRoleDemonstrations2022} showed that the mechanism of ICL is nontrivial and unintuitive, by empirically investigating LLM with ICL. They found that it is unnecessary to have correct in-context examples, and that the examples are mainly informative for other reasons. This showed the necessity in deeply explaining simple toy models of ICL.

\cite{chanDataDistributionalProperties2022} showed that pretrained LLM are better able to do ICL if the pretraining dataset has certain properties, such as non-IID, burstiness, long-tailed distributions, and contextuality. This can be intuitively interpreted as saying that LLM pretrained on generating text that resembles the prompt format of ICL are better at ICL. This motivates the toy model of \cite{gargWhatCanTransformers2022}, where the entire training dataset is purely ICL.

\section{Garg et al}

\cite{gargWhatCanTransformers2022} conducted a comprehensive study on the ICL capabilities of transformers across various simple function classes. Their work aimed to understand how effectively transformers can learn and generalize from a few input-output examples provided as context.

The study employed a setup where a transformer would be trained on different function classes, including linear, sparse linear, two-layer neural networks, and decision trees. The training process involved presenting the model with prompts containing input-output pairs and optimizing it to minimize the prediction error on unseen inputs.

The key aspects of this work are

\begin{enumerate}
	\item \textbf{Bayes optimal prediction:} For linear regression tasks, the trained transformers exhibited ICL behavior close to that of Bayesian predictors, which in this case means min-norm least squares regression.
	\item \textbf{Generalization:} The trained transformers generalized to new inputs, even in out-of-distribution (OOD) scenarios such as skewed input covariance, or different orthants.
	\item \textbf{Mechanistic interpretation:} For sparse linear regression, the trained transformers demonstrated performance comparable to iterative LASSO regression in a single pass. It was unclear how they performed this task, hinting at nontrivial mechanistic interpretation.
	\item \textbf{Curriculum learning:} If the complexity of tasks gradually increased from easy to hard, training speed and performance greatly increased.
\end{enumerate}

Each aspect of the work has been investigated further in subsequent work.

\section{Subsequent work}

\subsection{Optimality and generalization}

Many subsequent papers investigated the trained models, and typically found a three-step process: When the model has low capacity (shallow and narrow), the trained model would learn to perform one-step gradient descent. When the model has high capacity, the trained model would learn to perform Bayes-optimal prediction, often rivaling the best available algorithm.

Several studies interpret ICL through the lens of Bayesian inference. \cite{minNoisyChannelLanguage2022} propose a noisy channel model for text classification with LLMs, where the probability of an input given a label is proportional to the product of the likelihood and prior.

\cite{xieExplanationIncontextLearning2022} view ICL as implicit Bayesian inference, where the model integrates over possible concepts to generate outputs conditioned on the prompt.

These Bayesian interpretations suggest that LLMs may be performing a form of probabilistic reasoning, integrating prior knowledge with the information provided in the context to make predictions. This aligns with the observation that LLMs trained on diverse and realistic data exhibit better ICL capabilities, as such data provides a richer prior for the model to leverage.

Many empirical studies agree with \cite{gargWhatCanTransformers2022} that the trained model acts like a Bayes-optimal ICL with a prior distribution fitted to the training dataset.

However, several studies showed that under certain conditions, the trained model can generalize beyond the training dataset.

\cite{yadlowskyPretrainingDataMixtures2023} was the earliest subsequent work that tried mixtures of different function classes. They found that models trained on a balanced mixture had better generalization OOD, a finding confirmed subsequently.

\cite{raventosPretrainingTaskDiversity2024} show that with sufficient task diversity in the training set, ICL models can achieve near-optimal performance on unseen tasks, even surpassing Bayesian predictors based on the convex hull of the training data.

Similarly, \cite{panwarSurprisingDeviationsBayesian2023} and \cite{panwarInContextLearningBayesian2024} demonstrate that when exposed to a sufficiently diverse set of function classes during training, ICL models can generalize to entirely new classes, outperforming Bayesian predictors limited to the training set.

\section{Mechanistic interpretation}

A central question in ICL research is how LLMs encode information and perform computations within their layers to achieve their impressive performance. Several studies have investigated this aspect, revealing intriguing insights into the inner workings of ICL models.


\cite{guoHowTransformersLearn2023} investigated ICL for featurized linear regression, where the input undergoes a fixed non-linear transformation. They theoretically and empirically demonstrate that Transformers can effectively learn this task, with lower layers encoding the features and upper layers performing ridge regression.

\cite{pathakTransformersCanOptimally2023} trained models on ICL with mixture noisy linear models, achieving performance nearly on par with optimal oracle algorithm, despite having no access to the oracle information.

\cite{ahujaTransformersCanLearn2023} trained models on ICL with various linear inverse problems, obtaining models that resemble penalty-based and Bayesian approaches. They also show successful handling of mixed problem types, echoing findings from \cite{yadlowskyPretrainingDataMixtures2023}.

\subsection{Gradient descent}

A large cluster of subsequent work focused on interpreting the trained model as running varieties of gradient descent, or objections to this interpretation. Most of the supporting work are detailed in the section on theory.

The two papers that started this line of work are \cite{akyurekWhatLearningAlgorithm2023, vonoswaldTransformersLearnIncontext2023}, which constructed transformers implementing gradient descent and ridge regression, and found that trained models do agree with these algorithms. Low-capacity models would learn gradient descent, and high-capacity, ridge regression. \cite{vonoswaldTransformersLearnIncontext2023} also found that a learned model would in the early layers encode incoming tokens into a format amenable to GD, then performs GD in the later layers of the Transformer.

\cite{chengTransformersImplementFunctional2024} showed transformers learn \textit{functional} gradient descent, enabling them to learn non-linear functions.

\cite{fuTransformersLearnHigherOrder2023} objected that transformers learn a higher-order optimization method, i.e. Iterative Newton's Method.

\cite{dingCausalLMNotOptimal2024} showed that T5-like transformers outperform GPT-like autoregressive transformers, with the former converging to optimal solutions while the latter converges to gradient descent.

\cite{shenRevisitingHypothesisPretrained2024} found that, while transformers have the capacity to simulate gradient descent for ICL, real-world models like GPT-3 exhibit different behavior on ICL tasks compared to models trained specifically for ICL, bringing doubt to the practical relevance of the toy model.

\cite{mahdaviRevisitingEquivalenceInContext2024} revisit the equivalence between ICL and gradient descent, showing that strong assumptions like feature independence are needed for exact equivalence and that under weaker assumptions, the process resembles preconditioned gradient descent.

\subsection{Other mechanisms}

Other than gradient descent and linear algebraic algorithms, there were a few other proposed mechanisms. \cite{renIncontextLearningTransformer2023} proposed contrastive learning, \cite{hanExplainingEmergentInContext2023} kernel regression, \cite{reddyMechanisticBasisData2023} induction heads, \cite{abernethyMechanismSampleEfficientInContext2023} sequence segmentation.

\section{Theory}

Most theoretical studies based on \cite{gargWhatCanTransformers2022} has the following kinds of contents:

\begin{enumerate}
	\item \textbf{Existence by construction:} Write down the model parameters to perform an algorithm like gradient descent.
	\item \textbf{Convergence proof:} The model actually converges to a global or local optimum.
	\item \textbf{Mechanistic interpretation:} At the optimal point, the model performs some known algorithm like preconditioned gradient descent.
\end{enumerate}

For theoretical tractability, most of them analyzed only a single linear self-attention block trained by gradient flow. Most of them verify their theorems experimentally. We note where they differed from this. While one might doubt the realism of this simplification, \cite{ahnLinearAttentionMaybe2024} empirically shows that such models trained for linear regression ICL reproduce most of the interesting phenomena exhibited by a standard decoder-only transformer. On the other hand,  \cite{kimTransformersLearnNonlinear2024} highlight the role of feedforward layers in expanding the range of learnable functions to the Barron space, enabling greater flexibility in ICL.

\cite{baiTransformersStatisticiansProvable2023} constructed linear transformers for various statistical algorithms, including least squares, ridge regression, LASSO, and convex risk minimization. They also proved guarantees for expressive power, prediction performance, and sample complexity.

\cite{ahnTransformersLearnImplement2024} theoretically prove that linear transformers for ICL linear regression implement forms of preconditioned gradient descent, adapting to data distribution and variance.

\cite{linDualOperatingModes2024} proved dual operating modes (learning and retrieval) in linear transformers, explaining phenomena like "early ascent" and robustness to biased labels.

\cite{wuHowManyPretraining2024} proved a statistical task complexity bound, showing that with only a few linearly independent linear regression tasks, the trained model would perform close to Bayes optimal.

\cite{zhangTrainedTransformersLearn2024} proved convergence to a global minimum despite non-convexity. At the optimum, the model is nearly Bayes optimal estimator. \cite{zhangInContextLearningLinear2024} extended the convergence proof to a linear self-attention block followed by a feedforward layer, and that, the feedforward layer strictly improves the global optimum. At the optimum, the model implements one-step gradient descent with learnable initialization. \cite{zhangWhatHowDoes2023} explains the curve shape of Figure 2 of \cite{gargWhatCanTransformers2022}.

\cite{vladymyrovLinearTransformersAre2024} proved that, on noisy linear regression ICL tasks with unknown noise variance, linear transformers learn a gradient descent algorithm with noise-aware step-size adjustments and rescaling based on noise levels.

\cite{chenTrainingDynamicsMultiHead2024} analyzed the training dynamics of multi-head attention models for noisy multilinear regression, demonstrating convergence to a local minimum and identifying distinct phases in the learning process. Under another setting, \cite{huangInContextConvergenceTransformers2023} identified up to four distinct phases.

\cite{liTransformersAlgorithmsGeneralization2023} analyzed the problem from the PAC learning perspective, proving that the trained transformers are stable ICL learners, with provable generalization bounds to unseen tasks.

\section{Empirical advances}

Following up on the curriculum design work in \cite{gargWhatCanTransformers2022}, 
\cite{bhasinHowDoesMultiTask2024} experimented with different curriculum strategies across various function classes and statistical distributions, confirming its high efficiency.

Several papers tried different architectures than the autoregressive decoder-only transformer. \cite{grazziMambaCapableInContext2024} tried Mamba;  \cite{yangLoopedTransformersAre2024, gaoExpressivePowerVariant2024} tried looped transformers. 

\cite{liDissectingChainofThoughtCompositionality2023} trained models to perform difficult ICL tasks, where the function class is 6-layered MLP. This required sophisticated CoT prompting.

There were several ablation studies. \cite{wibisonoRoleUnstructuredTraining2023} shuffled input-output pairings in the prompt, and found the softmax layer was vital for "unshuffling" the data internally, acting as a mixture of experts. \cite{cuiSuperiorityMultiHeadAttention2024} found multi-headed attention superior to single-headed attention, particularly with noisy labels, local examples, and correlated features. \cite{xingBenefitsTransformerInContext2024} ablated components of the transformer, and found it important to include two attention layers with a look-ahead mask, positional encoding for connecting inputs and outputs, multi-head attention and high embedding dimensions.


\section{Others}

Some papers do not fit into a story, yet engages with \cite{gargWhatCanTransformers2022}, so we put all of them here.

\cite{gargNatureLearningLearning2023} is the first author's PhD thesis, and chapter 2 reprints \cite{gargWhatCanTransformers2022}.

\cite{bhattamishraUnderstandingInContextLearning2023} studied ICL with boolean function classes. They found that Transformers can nearly match the optimal learning algorithm for ‘simpler’ tasks, while their performance deteriorates on more ‘complex’ tasks. They also studied in-context curriculum, where simpler examples are presented earlier in the sequence. They also found that transformers can learn to implement two distinct algorithms to solve a single task, and can adaptively select the more sample-efficient algorithm depending on the sequence of in-context examples.

\cite{ahujaCloserLookInContext2023} pointed out two different forms of OOD. If $x$ all appear in one orthant during training, but are unrestricted during testing, then we still have $Pr_{testing}(y | P) = Pr_{training}(y | P)$ for any prompt $P$ , since we still do OLS in both cases. If $x$ are noiseless during training, but are noisy during testing, then we do not have $Pr_{testing}(y | P) = Pr_{training}(y | P)$ for any prompt $P$, because we need to do ridge regression in testing.

\cite{sreenivasanUnderstandingChallengesScaling2023} conducted theoretical and empirical studies on various ICL techniques, including variants of Chain of Thought (CoT) prompting, using \cite{gargWhatCanTransformers2022}'s codebase and incorporating curriculum learning strategies. 
