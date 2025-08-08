- ## Garg et al
	- gargWhatCanTransformers2022
		- Garg, Shivam, et al. "What can transformers learn in-context? a case study of simple function classes." *Advances in Neural Information Processing Systems* 35 (2022): 30583-30598.
	- SETUP.
		- ![image.png](../assets/image_1713402978233_0.png)
		- Given function distribution $D_F$ , input distribution $D_X$ , model $M_\theta$ , loss function $L$ .
		-
$$
		  f: \R^N \to \R^1, \quad \underbrace{f}_{\sim D_F}(\underbrace{x}_{\sim D_X}) = y
		  $$		- Sample a problem
$$x_1, \dots, x_n, x_{n+1} \sim D_X$$		- Construct prompts
$$P^0 = (x_1), P^1 = (x_1, f(x_1), x_2), P^2 = (x_1, f(x_1), x_2, f(x_2), x_3), \dots, P^n = (x_1, \dots, f(x_n), x_{n+1})$$ 		  where $P^i$ means a prompt that asks the model to compute $f$ on a new input, given $i$ examples.  
		- Construct loss on this problem
$$
		  L = \frac{1}{n+1} (l(M_\theta(x_1), f(x_1)) + l(M_\theta(x_2), f(x_2)) + \dots + l(M_\theta(x_{n+1}), f(x_{n+1})))
		  $$		- Learn the best model
$$
		  \theta^* = \argmin_\theta E\left[ L \right] 
		  $$	- model: autoregressive decoder, ranging from 3.4M to 22.4M params
		- from the GPT-2 family,
		- with 12 layers, 8 attention heads, and a 256-dimensional embedding space (when 22.4M parameters)
	- training
		- initialize model from scratch (no pretraining)
		- $l$ is squared loss
		- batch size of 64, train for 500k steps
		- curriculum: Start with a $D_F$ concentrated on a smaller set of simple functions, and then expand it out to the full $D_F$ of functions
			- e.g., linear functions with weight vectors restricted to a low-dimensional subspace
	- problems
		-
		  | problem type | $D_X$ | $D_F$ | good baseline | cheap baselines |
		  |---|---|---|---|---|
		  | linear | $N(0, I_{20})$ | $y = w^T x$ , where $w \sim N(0, I_{20})$ | least squares | 3 nearest neighbors, $w = E[yx]$ , $w = 0$ |
		  | sparse linear | $N(0, I_{20})$ | $y = w^T x$ , where $w$ has 3 random coordinates from $N(0, 1)$ , and the other 17 are zero | LASSO | least squares |
		  | two-layer NN | $N(0, I_{20})$ | ReLU activation, 100 hidden units | 2-layer NN gradient descent | least squares, 3 nearest neighbors |
		  | decision tree | $N(0, I_{20})$ | depth-4, full binary tree, each of 15 non-leaf nodes decides on a single different coordinate by positive/negative, 16 leaf nodes have values from $N(0, 1)$ | - | greedy, XGBoost, greedy on signs, XGBoost on signs |
	- ablations
		- problem dimension: $\{10, 20, 30, 40, 50\}$ . less is better
		- model param count: more parameters is better
		- in-distribution vs OOD: in-dist is better
			- skewed input covariance, and different orthants, are particularly challenging
		- curriculum learning: helps the model train faster, especially for high dim problems
		  collapsed:: true
			- we initially draw the prompt inputs from a fixed 5 dimensional subspace (by setting some of the coordinates to 0) with prompt length 11 (number of input-output pairs), and increase the subspace dimension by 1 and prompt length by 2 every 2, 000 training steps, until the subspace dimension reaches the ambient dimension $d$ and prompt length reaches $2d+1$
		- without curriculum, seems like there's a training loss phase transition
			- ![image.png](../assets/image_1713407412710_0.png)
		- number of different examples in the training set
			- ![image.png](../assets/image_1713412450479_0.png)
			- number of distinct prompts $P^i$ during training: possible with $1e4$ , good enough with $1e5$ , without ablation $3e7$
			- number of distinct functions $f$ during training: possible with $1e^3$ , good enough with $1e4$ , without ablation $3e7$
	- result
		- linear: seems to be doing Bayesian regression
			-
$$\lambda \mapsto M(x_1, \dots, f(x_n), \lambda x_{query})$$ 			   is straight and the same as the minnorm regression solution.  
			-
$$\nabla_{x_{query}} M(x_1, \dots, f(x_n),  x_{query})$$ 			   is close to the orthogonal projection of $w$ to the subspace spanned by $x_1, \dots, x_n$ .  
			- ![image.png](../assets/image_1713404892989_0.png)
		- linear, OOD: still seems to be doing Bayesian regression
			- When query equals one of the examples, it does similar to memorization.
			- When input is noisy, it still does as well as L2 regression.
			- When $x_{query} \perp x_1, \dots, x_n$ ,
$$M(x_1, \dots, f(x_n),  x_{query}) \approx 0$$			- skewed covariance: $x \sim N(0, \Sigma)$ where $\Sigma$ is a rotation of $diag(1, 1/4, 1/9, \dots, 1/400)$ .
			- low-dimensional subspace: $x \sim N(0, \Sigma)$ , where $\Sigma$ is a rotation of $diag(1^{10}, 0^{10})$ .
				- This is OOD if we use more than 10 in-context examples.
			- scaled $w$ and $x$ : robust to scaled $w$ , less so for $x$ .
			  collapsed:: true
				- ![image.png](../assets/image_1713412385847_0.png)
			- Different orthants
				- We fix the sign of each coordinate to be positive or negative for all in-context inputs (at random) at training time. Fix another set of signs at test time.
				- It does well. Thus the models is not relying on some nearest neighbor search
			- ![image.png](../assets/image_1713412310161_0.png)
		- sparse linear: does as well as LASSO, even though it's single-pass, whereas LASSO has no closed-form solution and must be iterative.
		- sign-based decision trees: better than greedy or XGBoost
			- we might be able to reverse engineer the algorithm encoded by a Transformer to obtain new sample efficient algorithms for existing learning problems
		- 20-100-1 ReLU NN: as well as full-batch Adam on the 20-100-1 ReLU NN.
		- 20-100-1 ReLU NN, OOD: can learn linear functions, better than NN, worse than least squares.
	- The model did not merely...
		- learn to nearest neighbor on in-context examples
			- It does well on the different orthants OOD case, even though nearest neighbor fails on that.
		- memorize training data
			- 32 million random weight vectors during training, and even using the best of these vectors would lead to an expected error of around 0.2. However, the model is able to achieve an error of less than 0.001 for a prompt with 2d in-context examples.
			- even when trained on prompts generated using only 10, 000 distinct weight vectors, in which case the best weight vector seen during training would yield an even worse error of around 0.5.