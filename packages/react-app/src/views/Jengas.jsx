import React, { useCallback, useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { Button, Card, List, Spin, Popover, Form, Switch, Input } from "antd";
import { RedoOutlined } from "@ant-design/icons";
import { Address, AddressInput } from "../components";
import { useDebounce } from "../hooks";
import { ethers } from "ethers";
import { useEventListener } from "eth-hooks/events/useEventListener";
import { PlayJengaModal } from "../components/Jenga";


function Jengas({
    readContracts, 
    mainnetProvider,
    blockExplorer,
    totalSupply,
    DEBUG,
    writeContracts,
    tx,
    address,
    localProvider,
    jengaContract,
    balance,
    startBlock,
}) {
    const [loadingJengas, setLoadingJengas] = useState(true);
    const [allJengas, setAllJengas] = useState({});
    const [yourJengas, setYourJengas]= useState();

    const [isModalVisible, setIsModalVisible] = useState(false);

    const perPage = 12;
    const [page, setPage] = useState(0);

    const fetchMetadataAndUpdate = async (id) => {
        try {
            const tokenURI = await readContracts[jengaContract].tokenURI(id);
            const jsonManifestString = atob(tokenURI.substring(29));
            
            try {
                const jsonManifest = JSON.parse(jsonManifestString);
                const collectibleUpdate = {};
                collectibleUpdate[id] = {id: id, uri: tokenURI, ...jsonManifest };
                
                
                setAllJengas(i => ({ ...i, ...collectibleUpdate }));
            } catch (e) {
                console.log("Json Manifest error: ", e);
            }
        } catch (e) {
            console.log("Token URI error: ", e);
        }
        
    };

    const updateOneJenga = async id => {
        if (readContracts[jengaContract] && totalSupply) {
            fetchMetadataAndUpdate(id);
        }
    }


    const updateAllJengas = async (fetchAll) => {
        if (readContracts[jengaContract] && totalSupply) {
            setLoadingJengas(true);
            let numberSupply = totalSupply;

            let tokenlist = Array(numberSupply).fill(0);

            tokenlist.forEach((_, i) => {
                let tokenId = i + 1;
                if (tokenId <= numberSupply - page * perPage && tokenId >= numberSupply - page *perPage -perPage) {
                    fetchMetadataAndUpdate(tokenId);
                } else if (!allJengas[tokenId]) {
                    const simpleUpdate = {};
                    simpleUpdate[tokenId] = { id: tokenId };
                    setAllJengas(i => ({ ...i, ...simpleUpdate }));
                }
            })
        }
    } 
    
    const updateYourJenga = async () => {
        collectibleUpdate = [];
        for (let tokenIndex=0; tokenIndex < balance; tokenIndex++) {
            try {
                const tokenId = await readContracts[jengaContract].tokenOfOwnerByIndex(address, tokenIndex);
                fetchMetadataAndUpdate(tokenId);
            } catch (e) {
                console.log("UpdateYourJenga eror: ", e);
            }
        }
    }
    //console.log("ALL JENGAS: ", allJengas)

    useEffect(() => {
        if (totalSupply ) updateAllJengas(false);
    }, [readContracts[jengaContract], (totalSupply || "0"),toString(), page]);

    // Filter the jengas to match the owner
    let filteredJengas = Object.values(allJengas).sort((a, b) => b.id - a.id);
    const [mine, setMine] = useState(false);
    if (mine == true && address && filteredJengas) {
        filteredJengas = filteredJengas.filter((jenga) => {
            return jenga.owner == address.toLowerCase();
        });
    }
    //console.log("filtered jengas: ", filteredJengas[0])

    return (
        <div style={{ width: "auto", margin: "auto", paddingBottom: 25, minHeight: 800 }}>
            
            {false ? (
                <Spin style={{ marginTop: 100 }} />
            ): (
                <div>
                    <div style={{ marginBottom: 5 }}>
                        <Button
                            onClick={() => {
                                return updateAllJengas(true);
                            }}
                        >
                            Refresh
                        </Button>
                        <Switch
                            disabled={loadingJengas}
                            style={{marginLeft: 5 }}
                            value={mine}
                            onChange={() => {
                                setMine(!mine);
                                updateYourJenga="all";
                            }}
                            checkedChildren="mine"
                            unCheckedChildren="all"
                        />
                    </div>
                <List
                    grid={{
                        gutter: 16,
                        xs: 1,
                        sm: 2,
                        md: 4,
                        lg: 4,
                        xl: 6,
                        xxl: 4,
                    }}
                    pagination={{
                        total: mine ? filteredOEs.length : totalSupply,
                        defaultPageSize: perPage,
                        defaultCurrent: page,
                        onChange: currentPage => {
                          setPage(currentPage - 1);
                          console.log(currentPage);
                        },
                        showTotal: (total, range) =>
                          `${range[0]}-${range[1]} of ${mine ? filteredOEs.length : totalSupply} items`,
                    }}
                    loading={false}
                    dataSource={filteredJengas ? filteredJengas: []}
                    renderItem={item => {
                        const id = item.id;

                        return (
                            
                            <List.Item key={id}>
                                {isModalVisible && (
                                    <PlayJengaModal 
                                        writeContracts={writeContracts}
                                        tx={tx}
                                        mainnetProvider={mainnetProvider}
                                        jengaContract={jengaContract}
                                        address={address}
                                        readContracts={readContracts}
                                        blockExplorer={blockExplorer}
                                        setIsModalVisible={setIsModalVisible}
                                        isModalVisible={isModalVisible}
                                        updateOneJenga={updateOneJenga}
                                        item={item}
                                    />
                                )}
                                <Card 
                                    //size needs to be bigger
                                    title={
                                        <div>
                                            <span style={{ fontSize: 18, marginRight: 8 }}>{item.name ? item.name : `Jenga #${id}`}</span>
                                            <Button
                                                shape="circle"
                                                oncClick={() => {
                                                    updateOneJenga(id);
                                                }}
                                                icon={<RedoOutlined />}
                                            />
                                        </div>
                                    }
                                >
                                    <a
                                        href={`${blockExplorer}token/${
                                            readContracts[jengaContract] && readContracts[jengaContract].address
                                        }?a=${id}`}
                                        target="_blank"
                                    >
                                        <img src={item.image && item.image} alt={"Jenga #" + id} width="150" />
                                    </a>
                                    {item.owner && 
                                        <div>
                                            <Address
                                                address={item.owner}
                                                ensProvider={mainnetProvider}
                                                blockExplorer={blockExplorer}
                                                fontSize={16}
                                            />
                                        </div>
                                    }
                                    {address && item.owner == address.toLowerCase() ? (
                                        <>
                                            {item.attributes[2].value == "standing" ? (
                                                <>
                                                    <Button
                                                        type="primary"
                                                        onClick={setIsModalVisible(true)}
                                                    >
                                                        Play
                                                    </Button>
                                                </>
                                            ) : (
                                                <h2> Game over, your tower grumbled!</h2>
                                            )}
                                        </>
                                    ) : (
                                        <>
                                            <Button
                                                type="primary"
                                                onClick={setIsModalVisible(true)}
                                            > 
                                                View 
                                            </Button>
                                        </>
                                    )}
                                </Card>

                            </List.Item>
                        );
                    }}
                />

                
                </div>
            )}
        </div>
    );
}

export default Jengas;