import numpy as np

def produce_random_numbers(k, n, m):
    matrix_a = np.random.randint(-1e3, 1e3, (k,n,m))
    matrix_b = np.random.randint(-1e3, 1e3, (k,n,m))

    np.savetxt("values_a.txt", matrix_a.reshape(k,-1), fmt='%1.1i', delimiter=' ')
    np.savetxt("values_b.txt", matrix_b.reshape(k,-1), fmt='%1.1i', delimiter=' ')

def check_result(k, n, m):
    matrix_a = np.reshape(np.loadtxt("values_a.txt", dtype=int), (k,n,m))
    matrix_b = np.reshape(np.loadtxt("values_b.txt", dtype=int), (k,n,m))
    result_hdl = np.reshape(np.loadtxt("product.txt", dtype=int), (k,n,n))

    for i in range(k):
        matrix_c = np.matmul(matrix_a[i], matrix_b[i])
        if np.array_equal(matrix_c, result_hdl[i]):
            print("Pass")
        else:
            print("Error")
            print("Matrix A\n", matrix_a[i])
            print("Matrix B\n", matrix_b[i])
            print("Correct result\n", matrix_c)
            print("Result from model\n", result_hdl[i])
