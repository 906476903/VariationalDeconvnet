require 'paths'

-- load dataset
function loadCifar(trsize,tesize,pad)
	local trainData = {
	   data = torch.Tensor(trsize, 3072),
	   labels = torch.Tensor(trsize),
	   size = function() return trsize end
	}

	for i = 0,math.ceil(trsize/10000)-1 do
	  local subset = torch.load('datasets/cifar-10-batches-t7/data_batch_' .. (i+1) .. '.t7', 'ascii')
	  trainData.data[{ {i*10000+1, (i+1)*10000} }] = subset.data:t()
	  trainData.labels[{ {i*10000+1, (i+1)*10000} }] = subset.labels
	end

	-- trainData.data = trainData.data:double()

	trainData.labels = trainData.labels + 1

	local subset = torch.load('datasets/cifar-10-batches-t7/test_batch.t7', 'ascii')
	local testData = {
	   data = subset.data:t():double(),
	   labels = subset.labels[1]:double(),
	   size = function() return tesize end
	}
	testData.labels = testData.labels + 1

	-- reshape data
	trainData.data = trainData.data:div(255):reshape(trsize,3,32,32)
	testData.data = testData.data:div(255):reshape(tesize,3,32,32)

	if pad then
		padded_data = torch.zeros(trsize,3,36,36)
		padded_data[{{},{},{3,34},{3,34}}] = trainData.data
		trainData.data = padded_data

		padded_data = torch.zeros(tesize,3,36,36)
		padded_data[{{},{},{3,34},{3,34}}] = testData.data
		testData.data = padded_data
	end

	return trainData,testData
end

function loadMnist()
	local trainData = {
	data = torch.load('mnist-t7/mnist_tr.t7') 
	}
	local testData = {
	data = torch.load('mnist-t7/mnist_te.t7')
	}
	trainData.data = trainData.data:reshape(50000,1,28,28)
	testData.data = testData.data:reshape(10000,1,28,28)

	return trainData, testData
end

function loadMnist_old()


	path_train = 'mnist-th7/train.th7'
	path_test = 'mnist-th7/test.th7'

	local f = torch.DiskFile(path_train, 'r')
	f:binary()
	local nExample = f:readInt()
    local dim = f:readInt()
    local tensor = torch.Tensor(nExample, dim)
    tensor:storage():copy(f:readFloat(nExample*dim))
    trainData = {
	data = tensor[{{1,50000},{1,784}}],
	labels = tensor[{{1,50000},{785}}]}
	testData = {
	data = tensor[{{50001,60000},{1,784}}],
	labels = tensor[{{50001,60000},{785}}]}

	trainData.data = trainData.data:div(255):reshape(trsize,28,28)
	testData.data = testData.data:div(255):reshape(tesize,28,28)
   
	return trainData, testData
end