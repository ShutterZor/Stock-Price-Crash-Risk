# Stock-Price-Crash-Risk

Calculating the index (NCSKEW and DUVOL) of Stock Price Crash Risk

# Equations

**首先**，需要根据个股收益率 $R_{i,t}$ 与市场收益率 $R_{m,t}$ 的回归方程估计残差。

$$
\begin{aligned}
R_{i,t} & =\epsilon_{i,t}+\alpha_{0}+\alpha_{1}R_{m,t-2}+\alpha_{2}R_{m,t-1} \\
        & +\alpha_{3}R_{m,t}+\alpha_{4}R_{m,t+2}+\alpha_{5}R_{m,t+2}
\end{aligned}
$$

**其次**，根据残差估计预期收益率/持有回报/特定收益率 $W_{i,t}$。

$$W_{i,t}=ln(1+\epsilon_{i,t})$$

**最后**，依次计算 $NCSKEW_{i,t}$ 与 $DUVOL_{i,t}$ 。

$$NCSKEW_{i,t}=-\frac{[n(n-1)^{3/2}\sum W_{i,t}^3]}{[(n-1)(n-2)(\sum W_{i,t}^2)^{3/2}]}$$

其中， $n$ 表示股票一年中的交易周数。

$$DUVOL_{i,t}=log\frac{(n_{u}-1)\sum_{D}W_{i,t}^2}{(n_{d}-1)\sum_{U}W_{i,t}^2}$$

其中， $n_u$ 表示其 $W_{i,t}$ 大于年平均 $W_{i,t}$ 的周数， $n_d$ 表示其 $W_{i,t}$ 小于年平均 $W_{i,t}$ 的周数。

# Code & Data

[GitHub](https://github.com/ShutterZor/Stock-Price-Crash-Risk)、[Gitee](https://gitee.com/Shutter_Zor/Stock-Price-Crash-Risk)

# Video & Post

[Bilibili/B站视频](https://www.bilibili.com/video/BV13s4y197ne/?vd_source=eabf2bfb3566fec2d8cf70a6545702f0)、[WeChat Official Account Post/微信公众号推文](https://mp.weixin.qq.com/s/ukHUKMMhaEVSCesQ6zhoEQ)
