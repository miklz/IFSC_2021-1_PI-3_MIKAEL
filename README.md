# IFSC_2021-1_PI-3_MIKAEL

Implementação de uma arquitetura sistólica para multiplicação de matrizes em FPGA

## Cronograma

- [ ] Desenhar o diagrama de blocos
- [ ] Pesquisar tipos de arquiteturas
- [ ] Configuração do SoC/FPGA
- [ ] Comunicação SoC com FPGA
- [ ] Implementação da arquitetura escolhida
- [ ] Debug e Revisão
- [ ] Treinamento de uma NN simples para testar o funcionamento
- [ ] Verificar a diferença do desempenho com e sem a implementação
- [ ] Documentar

## Diagrama de Blocos

Uma visão geral do funcionamento pode ser visto nesse diagrama.

![Diagrama de Blocos](./img/Diagrama_de_blocos.png)

Fonte: Autoria própria

Onde o processador faz uso do hardware físico para operações expecíficas e computacionalmente custosas. Nesse caso em particular uma rede neural embarcada utiliza o hardware especíalizado para fazer multiplicação de matrizes ou matriz e vetores.

## Arquitetura

O elemento mais básico de uma arquitetura sistólica é o unidade de processamento (processing element - PE), cada processador faz apenas uma computação e passa o resultado adiante.

![PE](./img/Processing_Element.png)

Fonte: [High-Performance Systolic Arrays for Band Matrix Multiplication](https://ieeexplore.ieee.org/document/1464792)

E essas unidade de processamentos podem ser organizadas em diferentes dimensões, 1D como um vetor, 2D como matriz e além. A seguinte figura mostra uma configuração em 3D.

![Cube](./img/PE_configuration.png)

Fonte: [An Efficient Parallel Algorithm for the All Pairs ShortestPath Problem using Processor Arrays withReconfigurable Bus Systems](https://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.1004.9008&rep=rep1&type=pdf)
