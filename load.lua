require 'paths'

-- load dataset
function loadCifar(trsize,tesize,pad)
	local trainData = {
	   data = torch.Tensor(50000, 3072),
	   labels = torch.Tensor(50000),
	   size = function() return trsize end
	}

	for i = 0,4 do
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
	trainData.data = trainData.data[{{1,trsize},{}}]
	testData.data = testData.data[{{1,tesize},{}}]
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
	--From: http://data.neuflow.org/data/mnist.t7.tgz
	local trainData = torch.load('datasets/mnist-t7/train_32x32.t7','ascii')
	local testData = torch.load('datasets/mnist-t7/test_32x32.t7','ascii')

	trainData.data = trainData.data:double():div(255)
	testData.data = testData.data:double():div(255)

	return trainData, testData
end
