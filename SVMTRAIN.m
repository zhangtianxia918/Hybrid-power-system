clc;clear;
a0=load('pload.txt'); 
state=load('state.txt');
%a=a0'; b0=a(:,[1:3558]); dd0=a(:,[3558:end]); %提取已分类和待分类的数据
m = size(a0, 1);

% Randomly select 720 data points to display
rand_indices = randperm(m);     % change the order -jin
rand_indices=rand_indices(1:720);
dd0=a0(rand_indices,:)';

z=a0;
z(rand_indices,:)=[];
b0=z';
state2=state(rand_indices,:);%代验证点的编号
state1=state;
state1(rand_indices,:)=[];   %训练点的编号
group=state1;

[b,ps]=mapstd(b0); %已分类数据的标准化
dd=mapstd('apply',dd0,ps); %待分类数据的标准化

% group0=load('state.txt'); %已知样本点的类别标号
% group=group0(1:3558);
option = statset('MaxIter',3000);
s= svmtrain( b', group, 'Kernel_Function', 'rbf', 'quadprog_opts', option ); 

% s=svmtrain( b', group,'Method','SMO','Kernel_Function','quadratic' ); %训练支持向量机分离器
% sv_index=s.SupportVectorIndices;  %返回支持向量的标号
beta=s.Alpha;  %返回分类函数的权系数
bb=s.Bias;  %返回分类函数的常数项
mean_and_std_trans=s.ScaleData; %第1行返回的是已知样本点均值向量的相反数，第2行返回的是标准差向量的倒数
check=svmclassify(s,b');  %验证已知样本点
err_rate=1-sum(group==check)/length(group)%计算已知样本点的错判率
solution=svmclassify(s,dd'); %对待判样本点进行分类
 err_rate2=1-sum(state2==solution)/length(state2)%验证集合的错误率
