# IFSC_2021-1_PI-3_MIKAEL

Implementação de uma arquitetura sistólica para multiplicação de matrizes em FPGA

## Cronograma

| Atividade | Cronograma |
|-----------|------------|
| [X] Desenhar o diagrama de blocos                                  | (04/06/2021) |
| [X] Pesquisar tipos de arquiteturas                                | (11/06/2021) |
| [X] Implementação da arquitetura escolhida                         | (25/06/2021) |
| [X] Testbench automátizado para validar a arquitetura              | (02/07/2021) |
| [ ] Configuração do SoC/FPGA                                       | (28/07/2021) |
| [ ] Comunicação SoC com FPGA                                       | (04/08/2021) |
| [ ] Debug e Revisão                                                | (11/08/2021) |
| [ ] Treinamento de uma NN simples para testar o funcionamento      | (18/08/2021) |
| [ ] Verificar a diferença do desempenho com e sem a implementação  | (25/08/2021) |
| [ ] Documentar                                                     | (05/08/2021) |

## Diagrama de Blocos

Uma visão geral do funcionamento pode ser visto nesse diagrama.

![Diagrama de Blocos](./img/Diagrama_de_blocos.png)

Fonte: Autoria própria

Onde o processador faz uso do hardware físico para operações expecíficas e 
computacionalmente custosas. Nesse caso em particular uma rede neural embarcada 
utiliza o hardware especializado para fazer multiplicação de matrizes ou matriz 
e vetores.

## Arquitetura Sistólica

O princípio básico de um sistema sistólico é a de minimizar a comunicação com 
dispositivos com alta latência (memória, I/O) e fazer o máximo possível com o 
dado em mãos. Algumas características dessa arquitetura é a sua simplicidade e 
regularidade e seu altissísimo nível de paralelização.

![Systolic System](./img/systolic_architecture.png)

Fonte: [Why Systolic Architectures?](https://www.cs.virginia.edu/~smk9u/CS4330S19/kung_-_1982_-_why_systolic_architectures.pdf)

O elemento mais básico de uma arquitetura sistólica é a unidade de processamento
(processing element - PE), cada célula faz apenas uma computação e passa o 
resultado adiante. Um exemplo de tal unidade pode ser visto aqui:

![PE](./img/Processing_Element.png)

Fonte: [High-Performance Systolic Arrays for Band Matrix Multiplication](https://ieeexplore.ieee.org/document/1464792)

E essas unidade de processamentos podem ser organizadas em diferentes dimensões,
1D como um vetor, 2D como matriz e além. A seguinte figura mostra uma 
configuração em 3D.

![Cube](./img/PE_configuration.png)

Fonte: [An Efficient Parallel Algorithm for the All Pairs Shortest Path Problem using Processor Arrays with Reconfigurable Bus Systems](https://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.1004.9008&rep=rep1&type=pdf)

As células podem ser dispostas em diferentes configurações para alcançar 
diferentes objetivos como filtros, operações com matrizes, e convoluções.
Um exemplo que eu achei complexo é o [calculo dos mínimos quadrados em tempo real usando uma arquitetura sistólica](http://www.eecs.harvard.edu/~htk/publication/1981-matrix-triangularization-by-systolic-arrays.pdf):

![Least Squares](./img/Least_squares_systolic.png)

Fonte: [Why Systolic Architectures?](https://www.cs.virginia.edu/~smk9u/CS4330S19/kung_-_1982_-_why_systolic_architectures.pdf)

### Multiplicação de matrizes

O objetivo desse projeto é o de fazer uso de uma arquitetura sistólica para a 
múltiplicação de matriz/matriz e matriz/vetor aliviando assim a carga para um 
processador de propósito geral. Na literatura há implementações para esse tipo 
de sistema algumas mais intuitivas que outras, fazendo uso ou não de matrizes 
esparças.

O sistema mais conhecido para mútiplicação de matriz/matriz é esse

![Standard multiply matrix](./img/standard_array.png)

Fonte: [A two-layered mesh array for matrix multiplication](https://www.sciencedirect.com/science/article/abs/pii/0167819188900786?via%3Dihub)

Mas como observado pelo artigo a latência para a solução disso é de 3n-2 onde n 
é a dimensão da matriz. Seguindo o artigo, pretendo implementar a seguinte 
configuração onde a latência é de 2n-1.

![Mesh multiply matrix](./img/mesh_array.png)

Fonte: [A two-layered mesh array for matrix multiplication](https://www.sciencedirect.com/science/article/abs/pii/0167819188900786?via%3Dihub)

## Testbench Automatizado

O script de automação foi feito em python, o workflow básico é o seguinte:
1. O script gera números aleatórios e grava isso em um arquivo.
2. O arquivo de testbench.vhd lê os valores gerados.
3. Os valores lidos são passados para a matriz que computa a multiplicação.
4. O resultado é armazenado em um arquivo.
5. O script em python lê os números gerados anteriormente computa a 
multiplicação e compara com o resultado do testbench.
6. Caso haja algum erro é exibido as entradas que produziram o resultado errado 
e mostra qual foi a resposta produzida pela arquitetura e qual é a resposta 
correta dada pelo modelo em python.

